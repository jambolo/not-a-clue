`
import MultipleCardChooser from './MultipleCardChooser'
import PlayerChooser from './PlayerChooser'

import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogTitle from '@mui/material/DialogTitle';
import Divider from '@mui/material/Divider';
import React, { Component } from 'react';
import Typography from '@mui/material/Typography'
`

class HandDialog extends Component
  constructor: (props) ->
    super props
    @state =
      playerId: null
      cardIds: []
    return

  close: ->
    @setState {
      playerId: null
      cardIds:[]
    }
    @props.onClose()
    return

  stateIsOk: -> @state.playerId? and @state.cardIds.length > 0

  handleClose: (event, reason) =>
    return if reason is 'backdropClick'
    @close()
    return

  handleChangePlayer: (playerId) =>
    @setState { playerId }
    return

  handleChangeCards: (cardId, selected) =>
    if selected
      @setState (state, props) -> 
        if cardId not in state.cardIds
          return { cardIds : state.cardIds.concat([cardId]) }
        else
          return null
    else
      @setState (state, props) -> 
        if cardId in state.cardIds
         return { cardIds : (id for id in state.cardIds when id isnt cardId) }
        else
         return null
    return

  handleDone: =>
    if @stateIsOk()
      @props.onDone @state.playerId, @state.cardIds
      @close()
    else
      @props.app.showConfirmDialog(
        "Error",
        "You must select a player and at least one card"
      )
    return

  handleCancel: =>
    @close()
    return

  render: ->
    { open, players, configuration, playerColors } = @props
    <Dialog open={open} fullScreen={true} onClose={@handleClose}>
      <DialogTitle id="form-dialog-title">Record Your Hand</DialogTitle>
      <DialogContent>
        <Typography variant="h6">Which player are you?</Typography>
        <PlayerChooser value={@state.playerId} players={players} playerColors={playerColors} onChange={@handleChangePlayer} />
        <Divider />
        <Typography variant="h6">Select the cards in your hand:</Typography>
        <MultipleCardChooser 
          value={@state.cardIds} 
          cards={configuration.cards} 
          types={configuration.types} 
          onChange={@handleChangeCards} 
        />
      </DialogContent>
      <DialogActions>
        <Button variant="contained" color="primary" onClick={@handleCancel}>Cancel</Button>
        <Button disabled={not @stateIsOk()} variant="contained" color="primary" onClick={@handleDone}>Done</Button>
      </DialogActions>
    </Dialog>

export default HandDialog
