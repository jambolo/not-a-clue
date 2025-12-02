`
import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';
import React, { Component } from 'react';
`

class ConfirmDialog extends Component
  handleYes: =>
    @props.yesAction() if @props.yesAction?
    @props.onClose()
    return

  handleNo: =>
    @props.noAction() if @props.noAction?
    @props.onClose()
    return

  render: ->
    { open, title, question, yesAction, noAction } = @props
    <Dialog
      open={open}
      onClose={(event, reason) =>
        return if reason in ['backdropClick', 'escapeKeyDown']
        @handleNo()
      }
    >
      <DialogTitle id="form-dialog-title">{title}</DialogTitle>
      <DialogContent>
        <DialogContentText>
          {question}
        </DialogContentText>
      </DialogContent>
      <DialogActions>
        {<Button variant="contained" color="primary" onClick={@handleNo}>{if yesAction? then "No" else "Cancel"}</Button> if noAction?}
        {<Button variant="contained" color="primary" onClick={@handleYes}>{if noAction? then "Yes" else "Ok"}</Button> if yesAction? or not noAction}
      </DialogActions>
    </Dialog>

export default ConfirmDialog
