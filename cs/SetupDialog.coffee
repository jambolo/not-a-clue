`
import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogTitle from '@mui/material/DialogTitle';
import Divider from '@mui/material/Divider';
import FormControlLabel from '@mui/material/FormControlLabel';
import FormControl from '@mui/material/FormControl';
import FormLabel from '@mui/material/FormLabel';
import Radio from '@mui/material/Radio';
import RadioGroup from '@mui/material/RadioGroup';
import React, { Component } from 'react';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import Stack from '@mui/material/Stack';
import Paper from '@mui/material/Paper';
import Alert from '@mui/material/Alert'
import Box from '@mui/material/Box'
import Chip from '@mui/material/Chip'
import IconButton from '@mui/material/IconButton'
import CloseIcon from '@mui/icons-material/Close'
import { buildPlayerColors } from './playerColors'
`
ConfigurationChoices = (props) ->
  { choice, configurations, numPlayers, onChange } = props

  <Stack spacing={1.5}>
    {
      for id, configuration of configurations
        isSelected = choice is id
        isDisabled = configuration.maxPlayers < numPlayers
        <Paper
          key={id}
          elevation={0}
          sx={{
            p: 2.5
            borderRadius: 3
            border: '2px solid'
            borderColor: if isSelected then 'primary.main' else 'divider'
            bgcolor: if isSelected then 'rgba(99, 102, 241, 0.04)' else 'background.paper'
            opacity: if isDisabled then 0.5 else 1
            cursor: if isDisabled then 'not-allowed' else 'pointer'
            transition: 'all 0.2s ease'
            '&:hover': if not isDisabled then { borderColor: 'primary.light', transform: 'translateY(-1px)' } else {}
          }}
          onClick={() -> onChange({ target: { value: id } }) if not isDisabled}>
          <FormControlLabel
            value={id}
            control={<Radio checked={isSelected} onChange={onChange} sx={{ display: 'none' }} />}
            label={
              <Stack spacing={0.5}>
                <Typography variant="subtitle1" sx={{ fontWeight: 600, color: 'text.primary' }}>{configuration.name}</Typography>
                <Typography variant="body2" color="text.secondary">
                  {configuration.minPlayers}–{configuration.maxPlayers} players · {Object.keys(configuration.cards).length} cards
                </Typography>
              </Stack>
            }
            disabled={isDisabled}
            sx={{ m: 0, width: '100%' }}
          />
        </Paper>
    }
  </Stack>

ConfigurationChooser = (props) ->
  <FormControl component="fieldset" fullWidth>
    <Typography variant="h6" sx={{ mb: 0.5, fontWeight: 600 }}>Select a variation</Typography>
    <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
      Choose the game edition that matches your board.
    </Typography>
    <ConfigurationChoices
      choice={props.choice}
      configurations={props.configurations}
      numPlayers={props.numPlayers}
      onChange={(event) -> props.onChange(event.target.value)}
    />
  </FormControl>

class AddPlayerInput extends Component
  constructor: (props) ->
    super props
    @state = 
      playerId: ""
    return

  handleChange: (event) =>
    @setState { playerId: event.target.value }
    return

  handleKeyDown: (event) =>
    if event.keyCode == 13 and @props.count < @props.max
      @handleAddPlayer()
    return

  handleAddPlayer: =>
    if @state.playerId isnt ""
      if @state.playerId isnt "ANSWER" and @state.playerId not in @props.players
        @props.onAddPlayer @state.playerId
      else
        @props.app.showConfirmDialog(
          "Error",
          "A player's name must be unique and it cannot be ANSWER."
        )
      @setState { playerId: "" }
    return

  render: ->
    <Stack direction="row" spacing={2} alignItems="flex-start" sx={{ mt: 1 }}>
      <TextField
        autoFocus
        label="Player name"
        placeholder="Enter a unique name"
        value={@state.playerId}
        onChange={@handleChange}
        onKeyDown={@handleKeyDown}
        helperText="Press Enter to add"
        size="small"
        sx={{ flexGrow: 1, maxWidth: 280 }}
      />
      <Button
        disabled={@props.count >= @props.max}
        variant="contained"
        color="primary"
        onClick={@handleAddPlayer}
        sx={{ mt: 0.5 }}>
        Add
      </Button>
    </Stack>

PlayerList = (props) ->
  colors = buildPlayerColors(props.names)
  return null if props.names.length == 0
  <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap sx={{ mt: 2 }}>
    {props.names.map((playerId, idx) =>
      <Chip
        key={playerId}
        label={playerId}
        sx={{
          bgcolor: colors[playerId]
          color: 'white'
          fontWeight: 600
          fontSize: '0.875rem'
        }}
      />
    )}
  </Stack>

AddPlayers = (props) ->
  { players, max, app, onAddPlayer, onClearPlayers } = props
  <Box>
    <AddPlayerInput
      players={players}
      count={players.length}
      max={max}
      app={app}
      onAddPlayer={onAddPlayer}
    />
    <PlayerList names={players} />
    {players.length > 0 and
      <Button
        variant="text"
        size="small"
        onClick={onClearPlayers}
        sx={{ mt: 2, color: 'text.secondary' }}>
        Clear all players
      </Button>
    }
  </Box>

class SetupDialog extends Component
  constructor: (props) ->
    super props
    @state =
      playerIds:       []
      configurationId: null
    return

  handleClose: (event, reason) =>
    return if reason is 'backdropClick'
    @props.onClose()
    return

  handleAddPlayer: (playerId) =>
    @setState (state, props) -> { playerIds: state.playerIds.concat([playerId]) }
    return

  handleClearPlayers: =>
    @setState { playerIds: [] }
    return

  handleChangeConfiguration: (configurationId) =>
    @setState { configurationId }
    return

  handleDone: =>
    @props.onDone @state.configurationId, @state.playerIds
    @props.onClose()
    return

  handleCancel: =>
    @props.onClose()
    return

  render: ->
    { open, configurations, app } = @props
    numPlayers = @state.playerIds.length
    minPlayers = if @state.configurationId then configurations[@state.configurationId].minPlayers else 0
    maxPlayers = if @state.configurationId then configurations[@state.configurationId].maxPlayers else 0

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
          <Typography variant="h5" sx={{ fontWeight: 700 }}>New Game</Typography>
          <Typography variant="body2" color="text.secondary">Set up your game session</Typography>
        </Box>
        <IconButton onClick={@handleCancel} sx={{ color: 'text.secondary' }}>
          <CloseIcon />
        </IconButton>
      </DialogTitle>
      <DialogContent sx={{ bgcolor: 'background.default', p: { xs: 2, md: 4 } }}>
        <Box sx={{ maxWidth: 600, mx: 'auto' }}>
          <Stack spacing={4}>
            <ConfigurationChooser
              choice={@state.configurationId}
              configurations={configurations}
              numPlayers={numPlayers}
              onChange={@handleChangeConfiguration}
            />
            <Divider />
            <Stack spacing={1}>
              <Typography variant="h6" sx={{ fontWeight: 600 }}>
                { if maxPlayers > 0 then "Add players (#{minPlayers}–#{maxPlayers})" else "Add players"}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Enter each player's name. Names must be unique.
              </Typography>
              <AddPlayers
                players={@state.playerIds}
                max={maxPlayers}
                app={app}
                onAddPlayer={@handleAddPlayer}
                onClearPlayers={@handleClearPlayers}
              />
              {
                if maxPlayers > 0 and numPlayers > 0
                  <Alert
                    severity={if numPlayers < minPlayers then 'info' else 'success'}
                    sx={{ mt: 2, borderRadius: 2 }}>
                    {numPlayers} of {minPlayers}–{maxPlayers} players added
                    {if numPlayers >= minPlayers then " — ready to play!" else "."}
                  </Alert>
              }
            </Stack>
          </Stack>
        </Box>
      </DialogContent>
      <DialogActions sx={{ px: 3, py: 2, borderTop: 1, borderColor: 'divider', gap: 1 }}>
        <Button variant="outlined" onClick={@handleCancel}>Cancel</Button>
        <Button
          disabled={not @state.configurationId? or numPlayers < minPlayers}
          variant="contained"
          color="primary"
          onClick={@handleDone}
          sx={{ px: 4 }}>
          Start game
        </Button>
      </DialogActions>
    </Dialog>

export default SetupDialog
