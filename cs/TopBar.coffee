import AppBar from '@mui/material/AppBar'
import IconButton from '@mui/material/IconButton'
import MenuIcon from '@mui/icons-material/Menu'
import React from 'react'
import Toolbar from '@mui/material/Toolbar'
import Typography from '@mui/material/Typography'
import Box from '@mui/material/Box'

TopBar = (props) ->
  <AppBar
    position="sticky"
    color="default"
    elevation={0}
    sx={{
      borderBottom: 1
      borderColor: 'divider'
      bgcolor: 'transparent'
      top: 0
      zIndex: 1100
    }}>
    <Toolbar sx={{ justifyContent: 'space-between', py: 1 }}>
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
        <IconButton
          onClick={(event) -> props.onMenu(event.currentTarget)}
          sx={{
            bgcolor: 'primary.main'
            color: 'white'
            '&:hover': { bgcolor: 'primary.dark' }
            width: 44
            height: 44
          }}>
          <MenuIcon />
        </IconButton>
        <Box>
          <Typography
            variant="h5"
            sx={{
              color: 'text.primary'
              fontWeight: 700
              letterSpacing: '-0.02em'
              lineHeight: 1.2
            }}>
            Not A Clue
          </Typography>
          <Typography
            variant="body2"
            sx={{
              color: 'text.secondary'
              fontWeight: 400
              mt: 0.25
            }}>
            Your deduction companion
          </Typography>
        </Box>
      </Box>
    </Toolbar>
  </AppBar>

export default TopBar
