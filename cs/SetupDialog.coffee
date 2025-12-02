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
import { buildPlayerColors } from './playerColors'
`
ConfigurationChoices = (props) ->
  { choice, configurations, numPlayers, onChange } = props

  <Stack spacing={1}>
    {
      for id, configuration of configurations
        <Paper key={id} variant={if choice is id then 'outlined' else 'elevation'} sx={{ p: 2, borderColor: if choice is id then 'primary.main' else undefined }}>
          <FormControlLabel
            value={id}
            control={<Radio checked={choice is id} onChange={onChange} /> }
            label=
              <Stack spacing={0.5}>
                <Typography variant="subtitle1" fontWeight={600}>{configuration.name}</Typography>
                <Typography variant="body2" color="text.secondary">
                  {configuration.minPlayers} - {configuration.maxPlayers} players · {Object.keys(configuration.cards).length} cards
                </Typography>
              </Stack>
            disabled={configuration.maxPlayers < numPlayers}
          />
        </Paper>
    }
  </Stack>

ConfigurationChooser = (props) ->
  <FormControl component="fieldset" fullWidth>
    <FormLabel component="legend"><Typography variant="h6">Select a variation</Typography></FormLabel>
    <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
      Choose the rule set that matches your board. Options that cannot support your player count are disabled.
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
    <div>
      <TextField
        autoFocus
        margin="normal"
        label="Player name"
        placeholder="Enter a unique name"
        value={@state.playerId}
        onChange={@handleChange}
        onKeyDown={@handleKeyDown}
        helperText="Press Enter to add quickly"
      />
      <Button
        disabled={@props.count >= @props.max}
        variant="contained"
        color="primary"
        onClick={@handleAddPlayer}
      >
        Add
      </Button>
    </div>

PlayerList = (props) ->
  colors = buildPlayerColors(props.names)
  <ol>
    {props.names.map((playerId) => <li key={playerId} style={{ color: colors[playerId], fontWeight: 600 }}> {playerId} </li>)}
  </ol>

AddPlayers = (props) ->
  { players, max, app, onAddPlayer, onClearPlayers } = props
  <div>
    <AddPlayerInput 
      players={players} 
      count={players.length} 
      max={max} 
      app={app}
      onAddPlayer={onAddPlayer} 
    />
    <PlayerList names={players} />
    <Button variant="contained" color="primary" onClick={onClearPlayers}>Clear Players</Button>
  </div>

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
      <DialogTitle id="form-dialog-title">New Game</DialogTitle>
      <DialogContent dividers sx={{ bgcolor: 'background.default' }}>
        <Stack spacing={3}>
          <ConfigurationChooser
            choice={@state.configurationId}
            configurations={configurations}
            numPlayers={numPlayers}
            onChange={@handleChangeConfiguration}
          />
          <Divider />
          <Stack spacing={1}>
            <Typography variant="h6">{ if maxPlayers > 0 then "Add up to #{maxPlayers} players" else "Add players"}</Typography>
            <Typography variant="body2" color="text.secondary">Player names must be unique and cannot use the reserved word ANSWER.</Typography>
            <AddPlayers
              players={@state.playerIds}
              max={maxPlayers}
              app={app}
              onAddPlayer={@handleAddPlayer}
              onClearPlayers={@handleClearPlayers}
            />
            {
              if maxPlayers > 0
                <Alert severity={if numPlayers < minPlayers then 'info' else 'success'}>
                  {numPlayers} of {minPlayers}–{maxPlayers} players added.
                </Alert>
            }
          </Stack>
        </Stack>
      </DialogContent>
      <DialogActions sx={{ px: 3, py: 2 }}>
        <Button variant="outlined" color="primary" onClick={@handleCancel}>Cancel</Button>
        <Button
          disabled={not @state.configurationId? or numPlayers < minPlayers}
          variant="contained"
          color="primary"
          onClick={@handleDone}
        >
          Start game
        </Button>
      </DialogActions>
    </Dialog>

export default SetupDialog
