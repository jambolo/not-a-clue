import Box from '@mui/material/Box'
import FormControlLabel from '@mui/material/FormControlLabel'
import Paper from '@mui/material/Paper'
import Radio from '@mui/material/Radio'
import RadioGroup from '@mui/material/RadioGroup'
import React from 'react'
import Stack from '@mui/material/Stack'
import Typography from '@mui/material/Typography'

PlayerChoices = (props) ->
  { value, players, excluded, onChange, playerColors } = props
  <RadioGroup name="players" value={value} onChange={onChange}>
    <Stack direction="row" spacing={1.5} flexWrap="wrap" useFlexGap>
      {
        for id in players
          color = if playerColors? then playerColors[id] else '#6366f1'
          isSelected = value == id
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
            onClick={() -> onChange({ target: { value: id } }) if not isDisabled}>
            <FormControlLabel
              value={id}
              control={<Radio size="small" sx={{ display: 'none' }} />}
              label={
                <Typography sx={{ color: color, fontWeight: 600, fontSize: '0.95rem' }}>{id}</Typography>
              }
              disabled={isDisabled}
              sx={{ m: 0 }}
            />
          </Paper>
      }
    </Stack>
  </RadioGroup>

PlayerChooser = (props) ->
  { value, players, excluded, onChange, playerColors } = props
  <Box>
    <PlayerChoices
      value={value}
      players={players}
      excluded={excluded}
      playerColors={playerColors}
      onChange={(event) -> onChange(event.target.value)}
    />
  </Box>

export default PlayerChooser
