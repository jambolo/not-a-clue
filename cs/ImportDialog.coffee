`
import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogTitle from '@mui/material/DialogTitle';
import React, { Component } from 'react';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography'
`

class ImportDialog extends Component
  constructor: (props) ->
    super props
    @state = 
      imported: ""
    return

  close: ->
    @setState { imported: "" }  
    @props.onClose()
    return

  handleClose: (event, reason) =>
    return if reason is 'backdropClick'
    @close()
    return

  handleChange: (event) =>
    @setState { imported: event.target.value }
    return

  handleCancel: =>
    @close()
    return

  handleDone: =>
    @props.onDone @state.imported
    @close()
    return

  render: ->
    { open } = @props
    <Dialog open={open} fullScreen={true} onClose={@handleClose}>
      <DialogTitle id="form-dialog-title"> Import </DialogTitle>
      <DialogContent>
      <Typography variant="h6"> Paste an exported log into the text field below: </Typography>
      <TextField 
        autoFocus 
        fullWidth={true}
        margin="normal"
        multiline={true}
        onChange={@handleChange}
        placeholder="Paste here."
        value={@state.imported} 
        variant="outlined"
      />
      </DialogContent>
      <DialogActions>
        <Button variant="contained" color="primary" onClick={@handleCancel}> Cancel </Button>
        <Button disabled={@state.imported.length == 0} variant="contained" color="primary" onClick={@handleDone}>
          Done
        </Button>
      </DialogActions>
    </Dialog>

export default ImportDialog
