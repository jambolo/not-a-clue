import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Dialog from '@mui/material/Dialog'
import DialogActions from '@mui/material/DialogActions'
import DialogContent from '@mui/material/DialogContent'
import DialogTitle from '@mui/material/DialogTitle'
import IconButton from '@mui/material/IconButton'
import CloseIcon from '@mui/icons-material/Close'
import UploadFileIcon from '@mui/icons-material/UploadFile'
import React, { Component } from 'react'
import Stack from '@mui/material/Stack'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'

class ImportDialog extends Component
  constructor: (props) ->
    super props
    @state =
      imported: ""
    @fileInputRef = React.createRef()
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

  handleFileClick: =>
    @fileInputRef.current?.click()
    return

  handleFileChange: (event) =>
    file = event.target.files?[0]
    return unless file
    reader = new FileReader()
    reader.onload = (e) =>
      @setState { imported: e.target.result }
    reader.readAsText(file)
    event.target.value = ''
    return

  render: ->
    { open } = @props
    <Dialog open={open} fullScreen={true} onClose={@handleClose}>
      <DialogTitle
        sx={{
          display: 'flex'
          alignItems: 'center'
          justifyContent: 'space-between'
          borderBottom: 1
          borderColor: 'divider'
          py: 2
          px: 3
        }}>
        <Box>
          <Typography variant="h5" sx={{ fontWeight: 700 }}>Import Session</Typography>
          <Typography variant="body2" color="text.secondary">Restore a previously exported game</Typography>
        </Box>
        <IconButton onClick={@handleCancel} sx={{ color: 'text.secondary' }}>
          <CloseIcon />
        </IconButton>
      </DialogTitle>
      <DialogContent sx={{ bgcolor: 'background.default', p: { xs: 2, md: 4 } }}>
        <Box sx={{ maxWidth: 600, mx: 'auto' }}>
          <Stack spacing={3}>
            <Box>
              <Typography variant="subtitle1" sx={{ fontWeight: 600, mb: 1 }}>Load from file</Typography>
              <input
                type="file"
                accept=".txt,.json"
                ref={@fileInputRef}
                onChange={@handleFileChange}
                style={{ display: 'none' }}
              />
              <Button
                variant="outlined"
                startIcon={<UploadFileIcon />}
                onClick={@handleFileClick}
                sx={{ mb: 2 }}>
                Choose File
              </Button>
            </Box>
            <Box>
              <Typography variant="subtitle1" sx={{ fontWeight: 600, mb: 1 }}>Or paste exported log</Typography>
              <TextField
                autoFocus
                fullWidth={true}
                multiline={true}
                minRows={8}
                onChange={@handleChange}
                placeholder="Paste exported session here..."
                value={@state.imported}
                variant="outlined"
              />
            </Box>
          </Stack>
        </Box>
      </DialogContent>
      <DialogActions sx={{ px: 3, py: 2, borderTop: 1, borderColor: 'divider', gap: 1 }}>
        <Button variant="outlined" onClick={@handleCancel}>Cancel</Button>
        <Button
          disabled={@state.imported.length == 0}
          variant="contained"
          color="primary"
          onClick={@handleDone}
          sx={{ px: 4 }}>
          Import
        </Button>
      </DialogActions>
    </Dialog>

export default ImportDialog
