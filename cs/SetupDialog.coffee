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
`
ConfigurationChoices = (props) ->
  { choice, configurations, numPlayers, onChange } = props

  <RadioGroup row name="variations" value={choice} onChange={onChange}>
    {
      for id, configuration of configurations
        <FormControlLabel 
          key={id} 
          value={id} 
          control={<Radio /> } 
          label={configuration.name}
          disabled={configuration.maxPlayers < numPlayers}
        /> 
    }
  </RadioGroup>

ConfigurationChooser = (props) ->
  <FormControl component="fieldset">
    <FormLabel component="legend"><Typography variant="h6">Select a variation:</Typography></FormLabel>
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
        value={@state.playerId} 
        onChange={@handleChange}
        onKeyDown={@handleKeyDown} 
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
  <ol>
    {props.names.map((playerId) => <li key={playerId}> {playerId} </li>)}
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
      <DialogContent>
        <ConfigurationChooser
          choice={@state.configurationId}
          configurations={configurations}
          numPlayers={numPlayers}
          onChange={@handleChangeConfiguration}
        />
        <Divider />
        <Typography variant="h6">{ if maxPlayers > 0 then "Add up to #{maxPlayers} players:" else "Add players:"}</Typography>
        <AddPlayers
          players={@state.playerIds}
          max={maxPlayers}
          app={app}
          onAddPlayer={@handleAddPlayer}
          onClearPlayers={@handleClearPlayers}
        />
      </DialogContent>
      <DialogActions>
        <Button variant="contained" color="primary" onClick={@handleCancel}>Cancel</Button>
        <Button 
          disabled={not @state.configurationId? or numPlayers < minPlayers} 
          variant="contained" 
          color="primary" 
          onClick={@handleDone}
        >
          Done
        </Button>
      </DialogActions>
    </Dialog>

export default SetupDialog
