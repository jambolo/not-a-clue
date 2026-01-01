`
import Box from '@mui/material/Box';
import Checkbox from '@mui/material/Checkbox';
import FormControlLabel from '@mui/material/FormControlLabel';
import Paper from '@mui/material/Paper';
import React, {Component} from 'react';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
`

class MultiplePlayerChooser extends Component

  makeChangeHandler: (id) =>
    (event) =>
      @props.onChange id, event.target.checked

  render:->
    { value, players, excluded, playerColors } = @props
    <Stack direction="row" spacing={1.5} flexWrap="wrap" useFlexGap>
      {
        for id in players
          color = if playerColors? then playerColors[id] else '#6366f1'
          isSelected = id in value
          isDisabled = excluded? and id in excluded
          <Paper
            key={id}
            elevation={0}
            sx={{
              px: 2.5
              py: 1.5
              borderRadius: 2
              border: '2px solid'
              borderColor: if isSelected then color else 'divider'
              bgcolor: if isSelected then "#{color}15" else 'background.paper'
              opacity: if isDisabled then 0.4 else 1
              cursor: if isDisabled then 'not-allowed' else 'pointer'
              transition: 'all 0.15s ease'
              '&:hover': if not isDisabled then { borderColor: color, transform: 'translateY(-1px)' } else {}
            }}
            onClick={() => @props.onChange(id, not isSelected) if not isDisabled}>
            <FormControlLabel
              value={id}
              control={
                <Checkbox
                  checked={isSelected}
                  disabled={isDisabled}
                  onChange={@makeChangeHandler(id)}
                  value={id}
                  size="small"
                  sx={{ display: 'none' }}
                />
              }
              label={<Typography sx={{ color: color, fontWeight: 600, fontSize: '0.95rem' }}>{id}</Typography>}
              sx={{ m: 0 }}
            />
          </Paper>
      }
    </Stack>

export default MultiplePlayerChooser
