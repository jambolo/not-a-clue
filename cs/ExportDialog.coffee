`
import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogTitle from '@mui/material/DialogTitle';
import Input from '@mui/material/Input';
import React from 'react';
import Typography from '@mui/material/Typography'
`

ExportDialog = (props) ->
    { open, log, onClose } = props
    handleDialogClose = (event, reason) ->
      return if reason is 'backdropClick'
      onClose()

    <Dialog open={open} fullScreen={true} onClose={handleDialogClose}>
      <DialogTitle id="form-dialog-title"> Export </DialogTitle>
      <DialogContent>
        <Typography component="h6"> Copy the JSON-formatted text below: </Typography>
        <Input autoFocus={true} fullWidth={true} multiline={true} value={JSON.stringify(log)} />
      </DialogContent>
      <DialogActions>
        <Button variant="contained" color="primary" onClick={onClose}> Done </Button>
      </DialogActions>
    </Dialog>

export default ExportDialog
