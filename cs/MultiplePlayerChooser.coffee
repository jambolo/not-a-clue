`
import Checkbox from '@mui/material/Checkbox';
import FormControlLabel from '@mui/material/FormControlLabel';
import FormGroup from '@mui/material/FormGroup';
import React, {Component} from 'react';
`

class MultiplePlayerChooser extends Component

  makeChangeHandler: (id) =>
    (event) =>
      @props.onChange id, event.target.checked

  render:->
    { value, players, excluded } = @props
    <FormGroup row>
      {
        for id in players
          <FormControlLabel
            key={id}
            value={id}
            control={
              <Checkbox
                checked={id in value}
                disabled={excluded? and id in excluded}
                onChange={@makeChangeHandler(id)}
                value={id}
              />
            } label={id}
          />
      }
    </FormGroup>

export default MultiplePlayerChooser
