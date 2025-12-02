`
import PerCategoryCardChooser from './PerCategoryCardChooser'
import MultiplePlayerChooser from './MultiplePlayerChooser'
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

class SuggestDialog extends Component
  constructor: (props) ->
    super props
    @state =
      suggesterId:   null
      cardIds:       {}
      showedIds:     []
      didNotShowIds: []
    return

  close: () ->
    @setState { suggesterId: null, cardIds: {}, showedIds: [], didNotShowIds: [] }
    @props.onClose()
    return

  stateIsOkMaster: ->
    cardCount = Object.keys(@state.cardIds).length
    return @state.suggesterId? and cardCount == 3 and @state.showedIds.length <= 3

  stateIsOkClassic: ->
    cardCount = Object.keys(@state.cardIds).length
    return @state.suggesterId? and cardCount == 3

  stateIsOk: -> if @props.configuration.rulesId is "master" then @stateIsOkMaster() else @stateIsOkClassic()

  handleClose: (event, reason) =>
    return if reason is 'backdropClick'
    @close()
    return

  handleChangeSuggesterId: (playerId) =>
    @setState { suggesterId: playerId }
    return

  handleChangeCards: (typeId, cardId) =>
    @setState (state, props) ->
      newCardIds = Object.assign({}, state.cardIds)
      newCardIds[typeId] = cardId
      return { cardIds: newCardIds }
    return

  handleChangeShowedIdsMaster: (playerId, selected) =>
    if selected
      @setState (state, props) ->
        return if playerId not in state.showedIds then { showedIds : state.showedIds.concat([playerId]) } else null
    else
      @setState (state, props) ->
        return if playerId in state.showedIds then { showedIds : (id for id in state.showedIds when id isnt playerId) } else null
    return

  handleChangeShowedIdsClassic: (playerId) =>
    @setState { showedIds: [playerId] }
    return

  handleChangeDidNotShowIdsClassic: (playerId, selected) =>
    if selected
      @setState (state, props) ->
        return if playerId not in state.didNotShowIds then { didNotShowIds : state.didNotShowIds.concat([playerId]) } else null
    else
      @setState (state, props) ->
        return if playerId in state.didNotShowIds then { didNotShowIds : (id for id in state.didNotShowIds when id isnt playerId) }  else null
    return

  handleDoneMaster: =>
    if not @stateIsOkMaster()
      @props.app.showConfirmDialog(
        "Error",
        "You must select a suggester, 3 cards, and up to 3 players who showed cards."
      )
      return
    cardIds = Object.values(@state.cardIds)
    if @state.showedIds.length == 0
      @props.app.showConfirmDialog(
        "Please confirm",
        "Are you sure that nobody showed any cards?",
        () =>       
          @props.onDone @state.suggesterId, cardIds, @state.showedIds
          @close()
        ,
        () -> {}
      )
      return
    @props.onDone @state.suggesterId, cardIds, @state.showedIds
    @close()
    return

  handleDoneClassic: =>
    if not @stateIsOkClassic()
      @props.app.showConfirmDialog(
        "Error",
        "You must select a suggester, 3 cards, and up to 3 players who showed cards."
      )
      return
    cardIds = Object.values(@state.cardIds)
    if not @state.showedIds[0]?
      @props.app.showConfirmDialog(
        "Please confirm",
        "Are you sure that nobody showed a card?",
        () =>       
          @props.onDone(@state.suggesterId, cardIds, [])
          @close()
        ,
        () -> {}
      )
      return
    @props.onDone @state.suggesterId, cardIds, @state.didNotShowIds.concat(@state.showedIds)
    @close()
    return

  handleDone: =>
    if @props.configuration.rulesId is "master"
      @handleDoneMaster()
    else
      @handleDoneClassic()
    return

  handleCancel: =>
    @close()
    return

  render: ->
    { open, players, configuration, playerColors } = @props
    <Dialog open={open} fullScreen={true} onClose={@handleClose}>
      <DialogTitle id="form-dialog-title">Record A Suggestion</DialogTitle>
      <DialogContent>
        <Typography variant="h4"> Who made the suggestion? </Typography>
        <PlayerChooser value={@state.suggesterId} players={players} playerColors={playerColors} onChange={@handleChangeSuggesterId} />
        <Divider />
        <Typography variant="h4"> What cards were suggested? </Typography>
        <PerCategoryCardChooser 
          value={@state.cardIds} 
          cards={configuration.cards} 
          types={configuration.types} 
          onChange={@handleChangeCards} 
        />
        <Divider />
        {
          if configuration.rulesId is "master"
            <div>
              <Typography variant="h4"> Who showed a card? </Typography>
              <MultiplePlayerChooser 
                value={@state.showedIds} 
                players={players} 
                playerColors={playerColors}
                excluded={if @state.suggesterId isnt null then [@state.suggesterId] else []} 
                onChange={@handleChangeShowedIdsMaster} 
              />
            </div>
          else
            <div>
              <Typography variant="h4"> Who did not have a card? </Typography>
              <MultiplePlayerChooser 
                value={@state.didNotShowIds} 
                players={players} 
                playerColors={playerColors}
                excluded={(
                  if @state.suggesterId isnt null
                    @state.showedIds.concat([@state.suggesterId])
                  else 
                    []
                )} 
                onChange={@handleChangeDidNotShowIdsClassic} 
              />
              <Typography variant="h4"> Who showed a card? </Typography>
              <PlayerChooser 
                value={@state.showedIds[0]} 
                players={players} 
                playerColors={playerColors}
                excluded={(
                  if @state.suggesterId isnt null 
                    @state.didNotShowIds.concat([@state.suggesterId]) 
                  else 
                    []
                )} 
                onChange={@handleChangeShowedIdsClassic} 
              />
            </div>
        }
      </DialogContent>
      <DialogActions>
        <Button variant="contained" color="primary" onClick={@handleCancel}> Cancel </Button>
        <Button disabled={not @stateIsOk()} variant="contained" color="primary" onClick={@handleDone}>
          Done
        </Button>
      </DialogActions>
    </Dialog>

export default SuggestDialog
