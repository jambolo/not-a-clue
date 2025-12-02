`
import AppBar from '@mui/material/AppBar';
import IconButton from '@mui/material/IconButton';
import MenuIcon from '@mui/icons-material/Menu';
import React from 'react';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
`

TopBar = (props) ->
  <AppBar position="static">
    <Toolbar>
      <IconButton color="inherit" onClick={(event) -> props.onMenu(event.currentTarget)}>
        <MenuIcon />
      </IconButton>
      <Typography variant="h6" color="inherit">
        Not A Clue
      </Typography>
    </Toolbar>
  </AppBar>

export default TopBar
