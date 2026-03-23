import Box from '@mui/material/Box'
import Chip from '@mui/material/Chip'
import FormControlLabel from '@mui/material/FormControlLabel'
import Paper from '@mui/material/Paper'
import Radio from '@mui/material/Radio'
import RadioGroup from '@mui/material/RadioGroup'
import React, { Component } from 'react'
import Stack from '@mui/material/Stack'
import Tab from '@mui/material/Tab'
import Tabs from '@mui/material/Tabs'
import Typography from '@mui/material/Typography'

CardList = (props) ->
  { selected, cards, types } = props
  selectedCount = Object.values(selected).filter((v) -> v?).length
  return null if selectedCount == 0
  <Box sx={{ mt: 2, p: 2, bgcolor: 'rgba(99, 102, 241, 0.04)', borderRadius: 2 }}>
    <Typography variant="subtitle2" color="text.secondary" sx={{ mb: 1 }}>Selected ({selectedCount}/3)</Typography>
    <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap>
      {
        for typeId, value of types when selected[typeId]?
          <Chip
            key={typeId}
            label={cards[selected[typeId]].name}
            color="primary"
            variant="outlined"
            size="small"
          />
      }
    </Stack>
  </Box>

CardChoices = (props) ->
  { value, type, cards, onChange } = props
  <RadioGroup name="cards" value={value} onChange={onChange}>
    <Stack spacing={1} sx={{ mt: 1 }}>
      {
        for id, info of cards when info.type is type
          isSelected = value == id
          <Paper
            key={id}
            elevation={0}
            sx={{
              p: 1.5
              px: 2
              borderRadius: 2
              border: '2px solid'
              borderColor: if isSelected then 'primary.main' else 'divider'
              bgcolor: if isSelected then 'rgba(99, 102, 241, 0.04)' else 'background.paper'
              cursor: 'pointer'
              transition: 'all 0.15s ease'
              '&:hover': { borderColor: 'primary.light' }
            }}
            onClick={() -> onChange({ target: { value: id } })}>
            <FormControlLabel
              value={id}
              control={<Radio size="small" sx={{ p: 0.5 }} />}
              label={<Typography sx={{ fontWeight: if isSelected then 600 else 400 }}>{info.name}</Typography>}
              sx={{ m: 0 }}
            />
          </Paper>
      }
    </Stack>
  </RadioGroup>

class PerCategoryCardChooser extends Component
  constructor: (props) ->
    super props
    @state =
      currentTab: 0
    return

  handleChangeTab: (event, currentTab) =>
    @setState { currentTab }
    return

  makeChangeEventHandler: (typeId) =>
    (event) =>
      @props.onChange typeId, event.target.value

  render: ->
    { value, cards, types } = @props
    tabIds = Object.keys(types)
    tabIndex = if @state.currentTab >= 0 and @state.currentTab < tabIds.length then @state.currentTab else 0
    tabId = tabIds[tabIndex]

    <Box>
      <Paper elevation={0} sx={{ borderRadius: 3, border: 1, borderColor: 'divider', overflow: 'hidden' }}>
        <Tabs
          value={tabIndex}
          onChange={@handleChangeTab}
          variant="fullWidth"
          sx={{
            bgcolor: 'background.paper'
            borderBottom: 1
            borderColor: 'divider'
            '& .MuiTab-root': { fontWeight: 600, py: 1.5 }
            '& .Mui-selected': { color: 'primary.main' }
          }}>
          {
            for id in tabIds
              hasSelection = value[id]?
              <Tab
                key={id}
                label={types[id].title}
                icon={if hasSelection then <Chip size="small" label="1" color="primary" sx={{ height: 20, minWidth: 20 }} /> else null}
                iconPosition="end"
              />
          }
        </Tabs>
        <Box sx={{ p: 2, maxHeight: 280, overflowY: 'auto' }}>
          <CardChoices
            value={value[tabId]}
            cards={cards}
            type={tabId}
            onChange={@makeChangeEventHandler(tabId)}
          />
        </Box>
      </Paper>
      <CardList selected={value} cards={cards} types={types} />
    </Box>

export default PerCategoryCardChooser
