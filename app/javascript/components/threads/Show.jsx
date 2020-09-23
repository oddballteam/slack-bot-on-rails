import React from 'react'
import PropTypes from 'prop-types'
import { Box, Button, Markdown, Text } from 'grommet'
import { Close, Info } from 'grommet-icons'

const ShowThread = props => {
  return (
    <Box fill="vertical" gap="medium">
      <Text>{props.started_at}</Text>
      <Button
        label="Slack Thread"
        icon={<Info />}
        primary
        href={props.permalink}
        target="details"
      />
      <Button
        label="Close"
        icon={<Close />}
        secondary
        onClick={props.onClose}
      />
    </Box>
  )
}

export default ShowThread
