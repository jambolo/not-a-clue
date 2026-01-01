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
import LinearProgress from '@mui/material/LinearProgress'
`

ActionButton = ({ label, onClick, color = "primary", icon }) ->
  <Button
    variant="contained"
    color={color}
    size="large"
    startIcon={icon}
    onClick={onClick}
    sx={{
      textTransform: 'none'
      minWidth: 120
      py: 1.5
      px: 3
      fontWeight: 600
      transition: 'all 0.2s ease'
      '&:hover': { transform: 'translateY(-2px)' }
    }}>
    {label}
  </Button>

EmptyState = ({ onStart }) ->
  <Card
    elevation={0}
    sx={{
      textAlign: 'center'
      p: { xs: 4, md: 6 }
      background: 'linear-gradient(135deg, rgba(99, 102, 241, 0.03) 0%, rgba(245, 158, 11, 0.03) 100%)'
      border: '2px dashed'
      borderColor: 'divider'
      borderRadius: 4
    }}>
    <Typography
      variant="h4"
      sx={{ mb: 2, fontWeight: 700, color: 'text.primary' }}>
      Welcome to Not A Clue
    </Typography>
    <Typography
      color="text.secondary"
      sx={{ mb: 4, maxWidth: 480, mx: 'auto', lineHeight: 1.7 }}>
      Start tracking your deductions and outsmart your opponents.
      Create a new game or import an existing session to begin.
    </Typography>
    <Button
      variant="contained"
      size="large"
      onClick={onStart}
      sx={{ px: 4, py: 1.5 }}>
      Start a new game
    </Button>
  </Card>

StatCard = ({ label, value, subtitle, progress, progressColor }) ->
  <Card
    sx={{
      height: '100%'
      background: 'linear-gradient(135deg, #ffffff 0%, #faf9f7 100%)'
      transition: 'all 0.2s ease'
      '&:hover': { transform: 'translateY(-2px)', boxShadow: 3 }
    }}>
    <CardContent sx={{ p: 2.5 }}>
      <Typography
        variant="overline"
        sx={{ color: 'text.secondary', fontWeight: 600, letterSpacing: 1 }}>
        {label}
      </Typography>
      <Typography
        variant="h5"
        sx={{ mt: 0.5, mb: 0.5, fontWeight: 700, color: 'text.primary' }}>
        {value}
      </Typography>
      {subtitle and <Typography variant="body2" color="text.secondary">{subtitle}</Typography>}
      {progress? and
        <LinearProgress
          variant="determinate"
          value={progress}
          color={progressColor or "primary"}
          sx={{ mt: 1.5, height: 6, borderRadius: 3 }}
        />
      }
    </CardContent>
  </Card>

Highlights = ({ configurationId, solver }) ->
  return null unless solver?
  totalCards = Object.keys(solver.cards).length
  knownCards = Object.values(solver.cards).filter((c) -> c.holderIsKnown()).length
  resolved = Object.values(solver.cards).filter((c) -> c.isHeldBy("ANSWER")).length
  playerCount = Object.keys(solver.players).length - 1
  knownPercent = Math.round((knownCards / totalCards) * 100)
  resolvedPercent = Math.round((resolved / 3) * 100)

  <Grid container spacing={2}>
    <Grid item xs={12}>
      <StatCard
        label="Game Mode"
        value={configurationId.replace('_', ' ').replace(/\b\w/g, (l) -> l.toUpperCase())}
        subtitle="#{playerCount} players in this game"
      />
    </Grid>
    <Grid item xs={6}>
      <StatCard
        label="Cards Known"
        value="#{knownCards}/#{totalCards}"
        progress={knownPercent}
        progressColor="primary"
      />
    </Grid>
    <Grid item xs={6}>
      <StatCard
        label="Solution"
        value="#{resolved}/3"
        progress={resolvedPercent}
        progressColor="success"
      />
    </Grid>
  </Grid>

MainView = (props) ->
  { configurationId, solver, app } = props
  { showHandDialog, showSuggestDialog, showShowDialog, showAccuseDialog, showCommlinkDialog, showNewGameDialog, showLog, showImportDialog } = app

  <Box className="MainView">
    <TopBar onMenu={props.onMenu} />
    <Box sx={{ px: { xs: 2, md: 4, lg: 6 }, py: { xs: 3, md: 4 }, maxWidth: 1400, mx: 'auto' }}>
      {
        if solver?
          <Stack spacing={4}>
            <Grid container spacing={3} alignItems="stretch">
              <Grid item xs={12} lg={8}>
                <Card sx={{ height: '100%' }}>
                  <CardContent sx={{ p: { xs: 2.5, md: 3.5 } }}>
                    <Typography variant="h5" sx={{ mb: 0.5 }}>Quick Actions</Typography>
                    <Typography color="text.secondary" variant="body2" sx={{ mb: 3 }}>
                      Record events as they happen during gameplay.
                    </Typography>
                    <Stack
                      spacing={2}
                      direction={{ xs: 'column', sm: 'row' }}
                      flexWrap="wrap"
                      useFlexGap>
                      <ActionButton label="Hand" onClick={showHandDialog} />
                      <ActionButton label="Suggest" onClick={showSuggestDialog} />
                      <ActionButton label="Show" onClick={showShowDialog} />
                      <ActionButton label="Accuse" onClick={showAccuseDialog} color="secondary" />
                      {
                        if (configurationId == "star_wars")
                          <ActionButton label="Commlink" onClick={showCommlinkDialog} />
                      }
                    </Stack>
                    <CardActions sx={{ px: 0, mt: 2, gap: 1 }}>
                      <Button
                        size="small"
                        onClick={showLog}
                        sx={{ fontWeight: 500 }}>
                        View log
                      </Button>
                      <Button
                        size="small"
                        onClick={showImportDialog}
                        sx={{ fontWeight: 500 }}>
                        Import session
                      </Button>
                    </CardActions>
                  </CardContent>
                </Card>
              </Grid>
              <Grid item xs={12} lg={4}>
                <Card sx={{ bgcolor: 'background.paper', height: '100%' }}>
                  <CardContent sx={{ p: { xs: 2.5, md: 3 } }}>
                    <Typography variant="h6" sx={{ mb: 2 }}>Session Stats</Typography>
                    <Highlights configurationId={configurationId} solver={solver} />
                  </CardContent>
                </Card>
              </Grid>
            </Grid>
            <Card>
              <CardContent sx={{ p: { xs: 2.5, md: 3.5 } }}>
                <Typography variant="h5" sx={{ mb: 0.5 }}>Deduction Table</Typography>
                <Typography color="text.secondary" variant="body2" sx={{ mb: 3 }}>
                  Track card ownership and narrow down the solution.
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
