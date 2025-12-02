`
import PerCategoryCardChooser from './PerCategoryCardChooser'
import PlayerChooser from './PlayerChooser'

import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogTitle from '@mui/material/DialogTitle';
import Divider from '@mui/material/Divider';
import FormControl from '@mui/material/FormControl';
import FormControlLabel from '@mui/material/FormControlLabel';
import Radio from '@mui/material/Radio';
import RadioGroup from '@mui/material/RadioGroup';
import React, { Component } from 'react';
import Typography from '@mui/material/Typography'
`

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

  handleChangeOutcome: (event) =>
    @setState { correct: event.target.value }
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
    { open, configuration, players } = @props
    <Dialog open={open} fullScreen={true} onClose={@handleClose}>
      <DialogTitle id="form-dialog-title">Record An Accusation</DialogTitle>
      <DialogContent>
        <Typography variant="h6">Who made the accusation?</Typography>
        <PlayerChooser value={@state.accuserId} players={players} onChange={@handleChangeAccuserId} />
        <Divider />
        <Typography variant="h6">What was the accusation?</Typography>
        <PerCategoryCardChooser 
          value={@state.cardIds} 
          cards={configuration.cards} 
          types={configuration.types} 
          onChange={@handleChangeCards} 
        />
        <Divider />
        <Typography variant="h6">Was the accusation correct?</Typography>
        <FormControl component="fieldset">
          <RadioGroup row name="outcome" value={@state.outcome} onChange={@handleChangeOutcome}>
            <FormControlLabel value={"yes"} control={<Radio />}  label="Yes" /> 
            <FormControlLabel value={"no"} control={<Radio />}  label="No" /> 
          </RadioGroup>
        </FormControl>
      </DialogContent>
      <DialogActions>
        <Button variant="contained" color="primary" onClick={@handleCancel}>Cancel</Button>
        <Button disabled={not @stateIsOk()} variant="contained" color="primary" onClick={@handleDone}>Done</Button>
      </DialogActions>
    </Dialog>

export default AccuseDialog
