`
import Box from '@mui/material/Box'
import Chip from '@mui/material/Chip'
import Grid from '@mui/material/Grid'
import Icon from '@mui/material/Icon'
import Paper from '@mui/material/Paper'
import React from 'react';
import Stack from '@mui/material/Stack'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'
`

Yes = (props) ->
  <Icon color={if props.isAnswer then "primary" else "success"} fontSize="small">
    {if props.isAnswer then "star" else "check_circle"}
  </Icon>

No = () -> ""

Maybe = () ->
  <Icon color="disabled" fontSize="small">
    indeterminate_check_box
  </Icon>

StateElement = (props) ->
  { card, player } = props

  if card.isHeldBy player
    <Yes isAnswer={player is "ANSWER"} />
  else if card.mightBeHeldBy player
    <Maybe />
  else
    <No />

HeaderRow = (props) ->
  { players, app } = props

  <Grid container item xs={12} alignItems="center" sx={{ py: 1, borderBottom: 1, borderColor: 'divider' }}>
    <Grid item xs={4}><Typography variant="subtitle2">Card</Typography></Grid>
    {<Grid item key={playerId} xs={1} textAlign="center"><Typography variant="subtitle2" sx={{ color: app.getPlayerColor(playerId), fontWeight: 700 }}>{playerId}</Typography></Grid> for playerId of players}
  </Grid>

StateRow = (props) ->
  {card, players} = props

  <Grid container item xs={12} alignItems="center" sx={{ py: 1, borderBottom: 1, borderColor: 'divider' }}>
    <Grid item xs={4}>
      <Typography fontWeight={if card.isHeldBy("ANSWER") then 700 else 500}>{card.info.name}</Typography>
      <Typography variant="caption" color="text.secondary">{card.info.type}</Typography>
    </Grid>
    {
      for playerId of players
        <Grid
          item
          key={playerId}
          xs={1}
          textAlign="center">
          <StateElement card={card} player={playerId} />
        </Grid>
    }
  </Grid>

Filters = ({ query, onQuery, showOnlyUnknown, onToggleUnknown }) ->
  <Stack spacing={2} direction={{ xs: 'column', md: 'row' }} sx={{ mb: 2 }}>
    <TextField
      label="Search cards"
      placeholder="Type to filter by name"
      value={query}
      onChange={(event) -> onQuery(event.target.value)}
      size="small"
    />
    <Chip
      label="Only unresolved"
      color={if showOnlyUnknown then "primary" else "default"}
      variant={if showOnlyUnknown then "filled" else "outlined"}
      onClick={onToggleUnknown}
    />
  </Stack>

CurrentState = (props) ->
  { cards, players } = props.solver
  { app } = props
  [query, setQuery] = React.useState("")
  [showOnlyUnknown, setShowOnlyUnknown] = React.useState(false)

  normalizedCards = Object.entries(cards).map(([id, card]) -> Object.assign(card, { id }))

  filteredCards = React.useMemo(() ->
    list = normalizedCards.filter((c) -> c.info.name.toLowerCase().includes(query.toLowerCase()))
    if showOnlyUnknown
      list = list.filter((c) -> not c.holderIsKnown())
    list.sort((a, b) -> a.info.type.localeCompare(b.info.type) or a.info.name.localeCompare(b.info.name))
    list
  , [normalizedCards, query, showOnlyUnknown])

  <Box>
    <Filters
      query={query}
      onQuery={setQuery}
      showOnlyUnknown={showOnlyUnknown}
      onToggleUnknown={() -> setShowOnlyUnknown((state) -> not state)}
    />
    <Paper variant="outlined" sx={{ overflowX: 'auto' }}>
      <Grid container>
        <HeaderRow players={players} app={app} />
        {<StateRow key={card.id} card={card} players={players} /> for card in filteredCards}
      </Grid>
      {
        if filteredCards.length == 0
          <Box sx={{ p: 2 }}>
            <Typography color="text.secondary">No cards match your filters. Try clearing the search.</Typography>
          </Box>
      }
    </Paper>
  </Box>

export default CurrentState
