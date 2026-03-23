import Box from '@mui/material/Box'
import Checkbox from '@mui/material/Checkbox'
import Chip from '@mui/material/Chip'
import FormControlLabel from '@mui/material/FormControlLabel'
import FormGroup from '@mui/material/FormGroup'
import Paper from '@mui/material/Paper'
import React, { Component } from 'react'
import Stack from '@mui/material/Stack'
import Tab from '@mui/material/Tab'
import Tabs from '@mui/material/Tabs'
import Typography from '@mui/material/Typography'

CardList = (props) ->
  { selected, cards, types } = props
  return null if selected.length == 0
  <Box sx={{ mt: 2, p: 2, bgcolor: 'rgba(99, 102, 241, 0.04)', borderRadius: 2 }}>
    <Typography variant="subtitle2" color="text.secondary" sx={{ mb: 1 }}>Your hand ({selected.length} cards)</Typography>
    <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap>
      {
        for id in selected
          <Chip
            key={id}
            label={cards[id].name}
            color="primary"
            variant="outlined"
            size="small"
          />
      }
    </Stack>
  </Box>

class CardChoices extends Component
  makeChangeHandler: (id) =>
    (event) =>
      @props.onChange id, event.target.checked

  render: ->
    { value, cards, excluded, type } = @props
    <Stack spacing={1} sx={{ mt: 1 }}>
      {
        for id, info of cards when info.type is type
          isSelected = id in value
          isDisabled = excluded? and id in excluded
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
              opacity: if isDisabled then 0.5 else 1
              cursor: if isDisabled then 'not-allowed' else 'pointer'
              transition: 'all 0.15s ease'
              '&:hover': if not isDisabled then { borderColor: 'primary.light' } else {}
            }}
            onClick={() => @props.onChange(id, not isSelected) if not isDisabled}>
            <FormControlLabel
              control={
                <Checkbox
                  checked={isSelected}
                  disabled={isDisabled}
                  onChange={@makeChangeHandler(id)}
                  value={id}
                  size="small"
                  sx={{ p: 0.5 }}
                />
              }
              label={<Typography sx={{ fontWeight: if isSelected then 600 else 400 }}>{info.name}</Typography>}
              sx={{ m: 0 }}
            />
          </Paper>
      }
    </Stack>

class MultipleCardChooser extends Component
  constructor: (props) ->
    super props
    @state =
      currentTab: 0
    return

  handleChangeTab: (event, currentTab) =>
    @setState { currentTab }
    return

  countSelectedInType: (typeId) ->
    { value, cards } = @props
    value.filter((id) -> cards[id].type == typeId).length

  render: ->
    { value, cards, types, excluded, onChange } = @props
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
              count = @countSelectedInType(id)
              <Tab
                key={id}
                label={types[id].title}
                icon={if count > 0 then <Chip size="small" label={count} color="primary" sx={{ height: 20, minWidth: 20 }} /> else null}
                iconPosition="end"
              />
          }
        </Tabs>
        <Box sx={{ p: 2, maxHeight: 280, overflowY: 'auto' }}>
          <CardChoices value={value} cards={cards} excluded={excluded} type={tabId} onChange={onChange} />
        </Box>
      </Paper>
      <CardList selected={value} cards={cards} types={types} />
    </Box>

export default MultipleCardChooser
