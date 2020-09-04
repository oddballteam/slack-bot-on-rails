import React from 'react'
// import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

const ListMessages = props => (
  <div>Hello {props.name}!</div>
)

ListMessages.defaultProps = {
  name: 'David'
}

ListMessages.propTypes = {
  name: PropTypes.string
}

export default ListMessages
