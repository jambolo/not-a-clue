`
import PerCategoryCardChooser from './PerCategoryCardChooser'
import MultiplePlayerChooser from './MultiplePlayerChooser'
import PlayerChooser from './PlayerChooser'

import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogTitle from '@mui/material/DialogTitle';
import Divider from '@mui/material/Divider';
import IconButton from '@mui/material/IconButton';
import CloseIcon from '@mui/icons-material/Close';
import React, { Component } from 'react';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography'
`

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
          <Typography variant="h5" sx={{ fontWeight: 700 }}>Record Suggestion</Typography>
          <Typography variant="body2" color="text.secondary">A suggestion was made during the game</Typography>
        </Box>
        <IconButton onClick={@handleCancel} sx={{ color: 'text.secondary' }}>
          <CloseIcon />
        </IconButton>
      </DialogTitle>
      <DialogContent sx={{ bgcolor: 'background.default', p: { xs: 2, md: 4 } }}>
        <Box sx={{ maxWidth: 600, mx: 'auto' }}>
          <Stack spacing={4}>
            <Box>
              <SectionHeader number={1} title="Who made the suggestion?" />
              <PlayerChooser value={@state.suggesterId} players={players} playerColors={playerColors} onChange={@handleChangeSuggesterId} />
            </Box>
            <Divider />
            <Box>
              <SectionHeader number={2} title="What cards were suggested?" subtitle="Select one card from each category" />
              <PerCategoryCardChooser
                value={@state.cardIds}
                cards={configuration.cards}
                types={configuration.types}
                onChange={@handleChangeCards}
              />
            </Box>
            <Divider />
            {
              if configuration.rulesId is "master"
                <Box>
                  <SectionHeader number={3} title="Who showed a card?" subtitle="Select all players who showed a card" />
                  <MultiplePlayerChooser
                    value={@state.showedIds}
                    players={players}
                    playerColors={playerColors}
                    excluded={if @state.suggesterId isnt null then [@state.suggesterId] else []}
                    onChange={@handleChangeShowedIdsMaster}
                  />
                </Box>
              else
                <Stack spacing={4}>
                  <Box>
                    <SectionHeader number={3} title="Who did not have a card?" subtitle="Select players who couldn't show anything" />
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
                  </Box>
                  <Divider />
                  <Box>
                    <SectionHeader number={4} title="Who showed a card?" subtitle="Select the player who showed a card (if any)" />
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
                  </Box>
                </Stack>
            }
          </Stack>
        </Box>
      </DialogContent>
      <DialogActions sx={{ px: 3, py: 2, borderTop: 1, borderColor: 'divider', gap: 1 }}>
        <Button variant="outlined" onClick={@handleCancel}>Cancel</Button>
        <Button
          disabled={not @stateIsOk()}
          variant="contained"
          color="primary"
          onClick={@handleDone}
          sx={{ px: 4 }}>
          Record
        </Button>
      </DialogActions>
    </Dialog>

export default SuggestDialog
