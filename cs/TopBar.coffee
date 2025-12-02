`
import AppBar from '@mui/material/AppBar';
import IconButton from '@mui/material/IconButton';
import MenuIcon from '@mui/icons-material/Menu';
import React from 'react';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box'
`

TopBar = (props) ->
  <AppBar position="static" color="default" elevation={0} sx={{ borderBottom: 1, borderColor: 'divider', bgcolor: 'white' }}>
    <Toolbar sx={{ justifyContent: 'space-between' }}>
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
        <IconButton color="primary" onClick={(event) -> props.onMenu(event.currentTarget)}>
          <MenuIcon />
        </IconButton>
        <Box>
          <Typography variant="h6" color="text.primary">Not A Clue</Typography>
          <Typography variant="body2" color="text.secondary">Clue companion for faster deductions</Typography>
        </Box>
      </Box>
    </Toolbar>
  </AppBar>

export default TopBar
