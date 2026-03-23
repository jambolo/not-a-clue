import PerCategoryCardChooser from './PerCategoryCardChooser'
import PlayerChooser from './PlayerChooser'

import Button from '@mui/material/Button'
import Box from '@mui/material/Box'
import Dialog from '@mui/material/Dialog'
import DialogActions from '@mui/material/DialogActions'
import DialogContent from '@mui/material/DialogContent'
import DialogTitle from '@mui/material/DialogTitle'
import Divider from '@mui/material/Divider'
import FormControl from '@mui/material/FormControl'
import FormControlLabel from '@mui/material/FormControlLabel'
import Paper from '@mui/material/Paper'
import Radio from '@mui/material/Radio'
import RadioGroup from '@mui/material/RadioGroup'
import React, { Component } from 'react'
import Stack from '@mui/material/Stack'
import Typography from '@mui/material/Typography'
import IconButton from '@mui/material/IconButton'
import CloseIcon from '@mui/icons-material/Close'

SectionHeader = ({ number, title, subtitle }) ->
  <Box sx={{ mb: 2 }}>
    <Stack direction="row" spacing={1.5} alignItems="center" sx={{ mb: 0.5 }}>
      <Box sx={{
        width: 28
        height: 28
        borderRadius: '50%'
        bgcolor: 'primary.main'
        color: 'white'
        display: 'flex'
        alignItems: 'center'
        justifyContent: 'center'
        fontSize: '0.875rem'
        fontWeight: 600
      }}>{number}</Box>
      <Typography variant="h6" sx={{ fontWeight: 600 }}>{title}</Typography>
    </Stack>
    {subtitle and <Typography variant="body2" color="text.secondary" sx={{ ml: 5 }}>{subtitle}</Typography>}
  </Box>

OutcomeButton = ({ value, selected, label, color, onClick }) ->
  <Paper
    elevation={0}
    onClick={onClick}
    sx={{
      p: 2
      px: 4
      borderRadius: 2
      border: '2px solid'
      borderColor: if selected then "#{color}.main" else 'divider'
      bgcolor: if selected then "#{color}.main" else 'background.paper'
      color: if selected then 'white' else 'text.primary'
      cursor: 'pointer'
      transition: 'all 0.2s ease'
      '&:hover': { borderColor: "#{color}.main", transform: 'translateY(-1px)' }
    }}>
    <Typography sx={{ fontWeight: 600 }}>{label}</Typography>
  </Paper>

class AccuseDialog extends Component
  constructor: (props) ->
    super props
    @state =
      accuserId: null
      cardIds:   {}
      correct:   null
    return

  close: ->
    @setState
      accuserId: null
      cardIds: {}
      correct: null
    @props.onClose()
    return

  stateIsOk: ->
    cardCount = Object.keys(@state.cardIds).length
    return @state.accuserId? and cardCount == 3 and @state.correct?

  handleClose: (event, reason) =>
    return if reason is 'backdropClick'
    @close()
    return

  handleChangeAccuserId: (playerId) =>
    @setState { accuserId: playerId }
    return

  handleChangeCards: (typeId, cardId) =>
    @setState (state, props) ->
      newCardIds = Object.assign({}, state.cardIds)
      newCardIds[typeId] = cardId
      return { cardIds: newCardIds }
    return

  handleChangeOutcome: (value) =>
    @setState { correct: value }
    return

  handleCancel: =>
    @close()
    return

  handleDone: =>
    if @stateIsOk()
      cardIds = Object.values(@state.cardIds)
      @props.onDone @state.accuserId, cardIds, @state.correct == "yes"
      @close()
    else
      @props.app.showConfirmDialog "Error", "You must select an accuser, 3 cards, and the outcome."
    return

  render: ->
    { open, configuration, players, playerColors } = @props
    <Dialog open={open} fullScreen={true} onClose={@handleClose}>
      <DialogTitle
        sx={{
          display: 'flex'
          alignItems: 'center'
          justifyContent: 'space-between'
          borderBottom: 1
          borderColor: 'divider'
          py: 2
          px: 3
        }}>
        <Box>
          <Typography variant="h5" sx={{ fontWeight: 700, color: 'secondary.main' }}>Record Accusation</Typography>
          <Typography variant="body2" color="text.secondary">An accusation was made during the game</Typography>
        </Box>
        <IconButton onClick={@handleCancel} sx={{ color: 'text.secondary' }}>
          <CloseIcon />
        </IconButton>
      </DialogTitle>
      <DialogContent sx={{ bgcolor: 'background.default', p: { xs: 2, md: 4 } }}>
        <Box sx={{ maxWidth: 600, mx: 'auto' }}>
          <Stack spacing={4}>
            <Box>
              <SectionHeader number={1} title="Who made the accusation?" />
              <PlayerChooser value={@state.accuserId} players={players} playerColors={playerColors} onChange={@handleChangeAccuserId} />
            </Box>
            <Divider />
            <Box>
              <SectionHeader number={2} title="What was the accusation?" subtitle="Select one card from each category" />
              <PerCategoryCardChooser
                value={@state.cardIds}
                cards={configuration.cards}
                types={configuration.types}
                onChange={@handleChangeCards}
              />
            </Box>
            <Divider />
            <Box>
              <SectionHeader number={3} title="Was the accusation correct?" />
              <Stack direction="row" spacing={2}>
                <OutcomeButton
                  value="yes"
                  selected={@state.correct == "yes"}
                  label="Yes, correct!"
                  color="success"
                  onClick={() => @handleChangeOutcome("yes")}
                />
                <OutcomeButton
                  value="no"
                  selected={@state.correct == "no"}
                  label="No, wrong"
                  color="error"
                  onClick={() => @handleChangeOutcome("no")}
                />
              </Stack>
            </Box>
          </Stack>
        </Box>
      </DialogContent>
      <DialogActions sx={{ px: 3, py: 2, borderTop: 1, borderColor: 'divider', gap: 1 }}>
        <Button variant="outlined" onClick={@handleCancel}>Cancel</Button>
        <Button
          disabled={not @stateIsOk()}
          variant="contained"
          color="secondary"
          onClick={@handleDone}
          sx={{ px: 4 }}>
          Record
        </Button>
      </DialogActions>
    </Dialog>

export default AccuseDialog
