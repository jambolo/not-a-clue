import Box from '@mui/material/Box'
import Chip from '@mui/material/Chip'
import Icon from '@mui/material/Icon'
import InputAdornment from '@mui/material/InputAdornment'
import Paper from '@mui/material/Paper'
import React from 'react'
import SearchIcon from '@mui/icons-material/Search'
import Stack from '@mui/material/Stack'
import Table from '@mui/material/Table'
import TableBody from '@mui/material/TableBody'
import TableCell from '@mui/material/TableCell'
import TableContainer from '@mui/material/TableContainer'
import TableHead from '@mui/material/TableHead'
import TableRow from '@mui/material/TableRow'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'

Yes = (props) ->
  <Box
    sx={{
      width: 24
      height: 24
      borderRadius: '50%'
      bgcolor: if props.isAnswer then 'primary.main' else 'success.main'
      display: 'flex'
      alignItems: 'center'
      justifyContent: 'center'
      mx: 'auto'
    }}>
    <Icon sx={{ color: 'white', fontSize: 16 }}>
      {if props.isAnswer then "star" else "check"}
    </Icon>
  </Box>

No = () ->
  <Box sx={{ width: 24, height: 24, mx: 'auto' }} />

Maybe = () ->
  <Box
    sx={{
      width: 24
      height: 24
      borderRadius: '50%'
      border: '2px dashed'
      borderColor: 'divider'
      mx: 'auto'
    }}
  />

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
  <TableRow sx={{ bgcolor: 'rgba(0, 0, 0, 0.02)' }}>
    <TableCell sx={{ fontWeight: 600, color: 'text.secondary', py: 1.5, pl: 2 }}>Card</TableCell>
    {
      for playerId of players
        <TableCell
          key={playerId}
          align="center"
          sx={{
            fontWeight: 700
            color: app.getPlayerColor(playerId)
            py: 1.5
            px: 1
            fontSize: '0.75rem'
            minWidth: 48
          }}>
          {playerId}
        </TableCell>
    }
  </TableRow>

StateRow = (props) ->
  { card, players, isHighlight } = props
  <TableRow
    sx={{
      bgcolor: if isHighlight then 'rgba(99, 102, 241, 0.04)' else 'transparent'
      '&:hover': { bgcolor: 'rgba(0, 0, 0, 0.02)' }
      transition: 'background-color 0.15s ease'
    }}>
    <TableCell sx={{ py: 1.5, pl: 2, borderBottom: 1, borderColor: 'divider' }}>
      <Typography
        sx={{
          fontWeight: if card.isHeldBy("ANSWER") then 700 else 500
          color: if card.isHeldBy("ANSWER") then 'primary.main' else 'text.primary'
        }}>
        {card.info.name}
      </Typography>
      <Typography variant="caption" sx={{ color: 'text.secondary', textTransform: 'capitalize' }}>
        {card.info.type}
      </Typography>
    </TableCell>
    {
      for playerId of players
        <TableCell
          key={playerId}
          align="center"
          sx={{ py: 1.5, px: 1, borderBottom: 1, borderColor: 'divider' }}>
          <StateElement card={card} player={playerId} />
        </TableCell>
    }
  </TableRow>

Filters = ({ query, onQuery, showOnlyUnknown, onToggleUnknown }) ->
  <Stack
    spacing={2}
    direction={{ xs: 'column', sm: 'row' }}
    alignItems={{ xs: 'stretch', sm: 'center' }}
    sx={{ mb: 3 }}>
    <TextField
      placeholder="Search cards..."
      value={query}
      onChange={(event) -> onQuery(event.target.value)}
      size="small"
      InputProps={{
        startAdornment: <InputAdornment position="start"><SearchIcon sx={{ color: 'text.secondary' }} /></InputAdornment>
      }}
      sx={{ minWidth: 220 }}
    />
    <Chip
      label={if showOnlyUnknown then "Showing unresolved only" else "Show unresolved only"}
      color={if showOnlyUnknown then "primary" else "default"}
      variant={if showOnlyUnknown then "filled" else "outlined"}
      onClick={onToggleUnknown}
      sx={{ fontWeight: 500 }}
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
    <TableContainer
      component={Paper}
      elevation={0}
      sx={{ border: 1, borderColor: 'divider', borderRadius: 3 }}>
      <Table size="small">
        <TableHead>
          <HeaderRow players={players} app={app} />
        </TableHead>
        <TableBody>
          {
            for card in filteredCards
              <StateRow
                key={card.id}
                card={card}
                players={players}
                isHighlight={card.isHeldBy("ANSWER")}
              />
          }
        </TableBody>
      </Table>
      {
        if filteredCards.length == 0
          <Box sx={{ p: 4, textAlign: 'center' }}>
            <Typography color="text.secondary">No cards match your filters.</Typography>
          </Box>
      }
    </TableContainer>
  </Box>

export default CurrentState
