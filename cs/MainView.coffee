`
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Card from '@mui/material/Card'
import CardActions from '@mui/material/CardActions'
import CardContent from '@mui/material/CardContent'
import Chip from '@mui/material/Chip'
import CurrentState from './CurrentState'
import Grid from '@mui/material/Grid'
import React from 'react';
import Stack from '@mui/material/Stack'
import TopBar from './TopBar'
import Typography from '@mui/material/Typography'
`

ActionButton = ({ label, onClick, color = "primary", icon }) ->
  <Button
    variant="contained"
    color={color}
    size="large"
    startIcon={icon}
    onClick={onClick}
    sx={{ textTransform: 'none', minWidth: 140 }}>
    {label}
  </Button>

EmptyState = ({ onStart }) ->
  <Card elevation={0} sx={{ textAlign: 'center', p: 4, border: '1px dashed', borderColor: 'divider' }}>
    <Typography variant="h5" gutterBottom>Welcome to Not A Clue</Typography>
    <Typography color="text.secondary" paragraph>
      Create a new game or import an existing session to start tracking your deductions.
      All controls are available in the top menu, and you can open quick actions once a game is running.
    </Typography>
    <Button variant="contained" size="large" onClick={onStart}>Start a new game</Button>
  </Card>

Highlights = ({ configurationId, solver }) ->
  return null unless solver?
  totalCards = Object.keys(solver.cards).length
  knownCards = Object.values(solver.cards).filter((c) -> c.holderIsKnown()).length
  resolved = Object.values(solver.cards).filter((c) -> c.isHeldBy("ANSWER")).length
  <Grid container spacing={2}>
    <Grid item xs={12} md={4}>
      <Card variant="outlined">
        <CardContent>
          <Typography variant="subtitle2" color="text.secondary">Variation</Typography>
          <Typography variant="h6" sx={{ mt: 0.5 }}>{configurationId.replace('_', ' ').toUpperCase()}</Typography>
          <Typography color="text.secondary" variant="body2">{Object.keys(solver.players).length - 1} players + the answer</Typography>
        </CardContent>
      </Card>
    </Grid>
    <Grid item xs={12} md={4}>
      <Card variant="outlined">
        <CardContent>
          <Typography variant="subtitle2" color="text.secondary">Known cards</Typography>
          <Typography variant="h6" sx={{ mt: 0.5 }}>{knownCards} / {totalCards}</Typography>
          <Chip size="small" label="Growing as you log clues" sx={{ mt: 1 }} />
        </CardContent>
      </Card>
    </Grid>
    <Grid item xs={12} md={4}>
      <Card variant="outlined">
        <CardContent>
          <Typography variant="subtitle2" color="text.secondary">Solution progress</Typography>
          <Typography variant="h6" sx={{ mt: 0.5 }}>{resolved} cards in the case file</Typography>
          <Typography color="text.secondary" variant="body2">Watch the table below for the latest deductions.</Typography>
        </CardContent>
      </Card>
    </Grid>
  </Grid>

MainView = (props) ->
  { configurationId, solver, app } = props
  { showHandDialog, showSuggestDialog, showShowDialog, showAccuseDialog, showCommlinkDialog, showNewGameDialog, showLog, showImportDialog } = app

  <Box className="MainView">
    <TopBar onMenu={props.onMenu} />
    <Box sx={{ px: { xs: 2, md: 4 }, py: 3 }}>
      {
        if solver?
          <Stack spacing={3}>
            <Grid container spacing={2} alignItems="stretch">
              <Grid item xs={12} md={8}>
                <Card elevation={1} sx={{ height: '100%' }}>
                  <CardContent>
                    <Typography variant="h5" gutterBottom>Quick actions</Typography>
                    <Typography color="text.secondary" variant="body2" gutterBottom>
                      Record discoveries as they happen to keep deductions up to date.
                    </Typography>
                    <Stack spacing={2} direction={{ xs: 'column', sm: 'row' }}>
                      <ActionButton label="Hand" onClick={showHandDialog} />
                      <ActionButton label="Suggest" onClick={showSuggestDialog} />
                      <ActionButton label="Show" onClick={showShowDialog} />
                      <ActionButton label="Accuse" onClick={showAccuseDialog} color="secondary" />
                      {
                        if (configurationId == "star_wars")
                          <ActionButton label="Commlink" onClick={showCommlinkDialog} />
                      }
                    </Stack>
                    <CardActions sx={{ px: 0, mt: 1 }}>
                      <Button size="small" onClick={showLog}>View log</Button>
                      <Button size="small" onClick={showImportDialog}>Import session</Button>
                    </CardActions>
                  </CardContent>
                </Card>
              </Grid>
              <Grid item xs={12} md={4}>
                <Card elevation={1} sx={{ bgcolor: 'background.paper', height: '100%' }}>
                  <CardContent>
                    <Typography variant="h6" gutterBottom>Session highlights</Typography>
                    <Typography color="text.secondary" variant="body2" gutterBottom>
                      A snapshot of your current game state.
                    </Typography>
                    <Highlights configurationId={configurationId} solver={solver} />
                  </CardContent>
                </Card>
              </Grid>
            </Grid>
            <Card elevation={1}>
              <CardContent>
                <Typography variant="h5" gutterBottom>Deduction table</Typography>
                <Typography color="text.secondary" variant="body2" gutterBottom>
                  Filter cards, focus on unresolved clues, and watch progress update live.
                </Typography>
                <CurrentState solver={solver} app={app} />
              </CardContent>
            </Card>
          </Stack>
        else
          <EmptyState onStart={showNewGameDialog} />
      }
    </Box>
  </Box>

export default MainView
