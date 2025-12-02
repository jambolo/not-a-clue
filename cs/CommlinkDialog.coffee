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


ShowedChooser = (props) ->
  value = if props.value then "yes" else "no"
  <FormControl component="fieldset">
    <RadioGroup row name="showed" value={value} onChange={props.onChange}>
      <FormControlLabel value="yes" control={<Radio />} label="Yes" /> 
      <FormControlLabel value="no" control={<Radio />} label="No" /> 
    </RadioGroup>
  </FormControl>

class CommlinkDialog extends Component
  constructor: (props) ->
    super props
    @state =
      callerId:   null
      receiverId: null
      cardIds:    {}
      showed:     false
    return

  close: ->
    @setState
      callerId:   null
      receiverId: null
      cardIds:    {}
      showed:     false
    @props.onClose()
    return

  stateIsOk: ->
    cardCount = Object.keys(@state.cardIds).length
    return @state.callerId? and @state.receiverId? and cardCount == 3

  handleChangeCallerId: (playerId) =>
    @setState { callerId: playerId }
    return

  handleChangeSubjectId: (playerId) =>
    @setState { receiverId: playerId }
    return

  handleChangeCards: (typeId, cardId) =>
    @setState (state, props) ->
      newCardIds = Object.assign({}, state.cardIds)
      newCardIds[typeId] = cardId
      return { cardIds: newCardIds }
    return

  handleChangeShowed: (event) =>
    @setState { showed: event.target.value is "yes" }
    return
  handleClose: (event, reason) =>
    return if reason is 'backdropClick'
    @close()
    return

  handleDone: =>
    if @stateIsOk()
      cardIds = Object.values(@state.cardIds)
      @props.onDone @state.callerId, @state.receiverId, cardIds, @state.showed
      @close()
    else
      @props.app.showConfirmDialog("Error", "You must select an caller, a receiver, and one card of each type.")
    return

  handleCancel: =>
    @close()
    return

  render: ->
    { open, players, configuration, playerColors } = @props
    <Dialog open={open} fullScreen={true} onClose={@handleClose}>
      <DialogTitle id="form-dialog-title"> Record A Commlink </DialogTitle>
      <DialogContent>
        <Typography variant="h4"> Who is the caller? </Typography>
        <PlayerChooser 
          value={@state.callerId} 
          players={players} 
          playerColors={playerColors}
            excluded={if @state.receiverId? then [@state.receiverId] else []} 
          onChange={@handleChangeCallerId} 
        />
        <Divider />
        <Typography variant="h4"> Who is the receiver? </Typography>
        <PlayerChooser 
          value={@state.receiverId} 
          players={players} 
          playerColors={playerColors}
            excluded={if @state.callerId? then [@state.callerId] else []} 
          onChange={@handleChangeSubjectId} 
          />
        <Divider />
        <Typography variant="h4"> Which cards? </Typography>
        <PerCategoryCardChooser 
          value={@state.cardIds} 
          cards={configuration.cards} 
          types={configuration.types} 
          onChange={@handleChangeCards} 
        />
        <Divider />
          <Typography variant="h4"> Was a card shown? </Typography>
          <ShowedChooser 
            value={@state.showed} 
            onChange={@handleChangeShowed} 
          />
      </DialogContent>
      <DialogActions>
        <Button variant="contained" color="primary" onClick={@handleCancel}>Cancel</Button>
        <Button disabled={not @stateIsOk()} variant="contained" color="primary" onClick={@handleDone}>Done</Button>
      </DialogActions>
    </Dialog>

export default CommlinkDialog
