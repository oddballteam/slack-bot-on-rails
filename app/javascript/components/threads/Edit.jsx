import React from 'react'
import PropTypes from 'prop-types'
import { Grommet, Box, Button, Form, FormField, Keyboard, TextArea, TextInput } from 'grommet'
import { Close, Info } from 'grommet-icons'

const EditThread = props => {
  const focusRef = React.useRef()

  const nullsToEmptyStrings = obj => {
    Object.keys(obj).forEach(key => {
      if (obj[key] == null) obj[key] = ''
      if (Array.isArray(obj[key])) obj[key] = obj[key].join('; ')
    })
    return obj
  }
  const [value, setValue] = React.useState(nullsToEmptyStrings({...props.item}))

  React.useEffect(() => {
    focusRef.current.focus()
    if (value.id != props.item.id)
    {
      setValue(nullsToEmptyStrings(props.item))
    }
  }, [props.item.id])

  const isCtrlOrCmdEnter = (key, e) => (key == 13 && (e.metaKey || e.ctrlKey))

  const onKeyDown = e => {
    const key = e.keyCode || e.which
    if (isCtrlOrCmdEnter(key, e) && props.onSubmit) props.onSubmit(value)
    if (key == 27 && props.onClose) props.onClose(e)
  }

  return (
    <Grommet>
      <Keyboard onKeyDown={onKeyDown}>
        <Form
          errors={props.errors}
          value={value}
          onChange={nextValue => setValue(nextValue)}
          onReset={() => setValue({})}
          onSubmit={() => props.onSubmit(value)}
        >
          <Box fill="vertical">
            <FormField
              label="Started At"
              name="started_at"
            >
              <TextInput ref={focusRef} name="started_at" />
            </FormField>
            <Button
              label="Slack Thread"
              icon={<Info />}
              primary
              href={props.item.permalink}
              target="details"
            />
            <FormField
              label="Categories"
              name="category_list"
            />
            <FormField
              label="Note(s)"
              name="note"
              placeholder="Supports _markdown_!"
              fill="vertical"
            >
              <TextArea name="note" fill size="small" />
            </FormField>
            <Button
                label="Close"
                icon={<Close />}
                secondary
                onClick={props.onClose}
              />
          </Box>
        </Form>
      </Keyboard>
    </Grommet>
  );
}

EditThread.propTypes = {
  errors: PropTypes.object,
  item: PropTypes.object,
  onClose: PropTypes.func,
  onDelete: PropTypes.func,
  onSubmit: PropTypes.func,
}

export default EditThread
