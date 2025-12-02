`
import FormControl from '@mui/material/FormControl';
import FormControlLabel from '@mui/material/FormControlLabel';
import Radio from '@mui/material/Radio';
import RadioGroup from '@mui/material/RadioGroup';
import React from 'react';
`

PlayerChoices = (props) ->
  { value, players, excluded, onChange } = props
  <RadioGroup row name="players" value={value} onChange={onChange}>
    {
      for id in players
        <FormControlLabel 
          key={id} 
          value={id} 
          control={<Radio />} 
          label={id} 
          disabled={excluded? and id in excluded}
        /> 
    }
  </RadioGroup>

PlayerChooser = (props) ->
  { value, players, excluded, onChange } = props
  <FormControl component="fieldset">
    <PlayerChoices
      value={value}
      players={players}
      excluded={excluded}
      onChange={(event) -> onChange(event.target.value)}
    />
  </FormControl>

export default PlayerChooser
