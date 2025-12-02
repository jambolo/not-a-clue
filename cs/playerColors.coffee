palette = [
  '#ef4444' # red
  '#f59e0b' # amber
  '#eab308' # golden yellow
  '#84cc16' # lime
  '#22c55e' # green
  '#14b8a6' # teal
  '#06b6d4' # cyan
  '#2563eb' # blue (distinct from primary)
  '#7c3aed' # purple
  '#ec4899' # pink
]

buildPlayerColors = (playerIds) ->
  colors = {}
  for id, idx in playerIds
    colors[id] = palette[idx % palette.length]
  colors["ANSWER"] = '#111827'
  colors

playerColorFor = (colors, playerId) ->
  colors?[playerId] or '#6b7280'

export { buildPlayerColors, playerColorFor }
