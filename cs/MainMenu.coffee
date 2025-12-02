`
import Menu from '@mui/material/Menu'
import MenuItem from '@mui/material/MenuItem'
import React, { Component } from 'react';
`

version = require './version'

class MainMenu extends Component
  handleStart: =>
    @props.app.showNewGameDialog()
    @props.onClose()
    return

  handleLog: =>
    @props.app.showLog()
    @props.onClose()
    return

  handleExport: =>
    @props.app.showExportDialog()
    @props.onClose()
    return

  handleImport: =>
    @props.app.showImportDialog()
    @props.onClose()
    return

  render: ->
    { anchor, started, onClose} = @props
    <Menu id="main-menu" anchorEl={anchor} open={Boolean(anchor)} onClose={onClose}>
      <MenuItem onClick={@handleStart}> Start New Game </MenuItem>
      <MenuItem onClick={@handleImport}> Import Log </MenuItem>
      <MenuItem disabled={not started} onClick={@handleLog}> Show Log </MenuItem>
      <MenuItem disabled={not started} onClick={@handleExport}> Export Log </MenuItem>
      <MenuItem disabled={true}> {version} </MenuItem>
    </Menu>

export default MainMenu
