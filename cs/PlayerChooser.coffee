`
import FormControl from '@mui/material/FormControl';
import FormControlLabel from '@mui/material/FormControlLabel';
import Radio from '@mui/material/Radio';
import RadioGroup from '@mui/material/RadioGroup';
import React from 'react';
`

PlayerChoices = (props) ->
  { value, players, excluded, onChange, playerColors } = props
  <RadioGroup row name="players" value={value} onChange={onChange}>
    {
      for id in players
        color = if playerColors? then playerColors[id] else undefined
        <FormControlLabel 
          key={id} 
          value={id} 
          control={<Radio />} 
          label={<span style={{ color: color, fontWeight: 600 }}>{id}</span>} 
          disabled={excluded? and id in excluded}
          sx={{ color: color }}
        /> 
    }
  </RadioGroup>

PlayerChooser = (props) ->
  { value, players, excluded, onChange, playerColors } = props
  <FormControl component="fieldset">
    <PlayerChoices
      value={value}
      players={players}
      excluded={excluded}
      playerColors={playerColors}
      onChange={(event) -> onChange(event.target.value)}
    />
  </FormControl>

export default PlayerChooser
