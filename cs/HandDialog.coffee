`
import MultipleCardChooser from './MultipleCardChooser'
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
          <Typography variant="h5" sx={{ fontWeight: 700 }}>Record Your Hand</Typography>
          <Typography variant="body2" color="text.secondary">Tell us which cards you're holding</Typography>
        </Box>
        <IconButton onClick={@handleCancel} sx={{ color: 'text.secondary' }}>
          <CloseIcon />
        </IconButton>
      </DialogTitle>
      <DialogContent sx={{ bgcolor: 'background.default', p: { xs: 2, md: 4 } }}>
        <Box sx={{ maxWidth: 600, mx: 'auto' }}>
          <Stack spacing={4}>
            <Box>
              <SectionHeader number={1} title="Which player are you?" />
              <PlayerChooser value={@state.playerId} players={players} playerColors={playerColors} onChange={@handleChangePlayer} />
            </Box>
            <Divider />
            <Box>
              <SectionHeader number={2} title="Select the cards in your hand" subtitle="Check all cards you were dealt" />
              <MultipleCardChooser
                value={@state.cardIds}
                cards={configuration.cards}
                types={configuration.types}
                onChange={@handleChangeCards}
              />
            </Box>
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
          Save
        </Button>
      </DialogActions>
    </Dialog>

export default HandDialog
