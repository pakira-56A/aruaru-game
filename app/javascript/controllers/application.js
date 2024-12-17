import { Application } from "@hotwired/stimulus"
import { Autocomplete } from 'stimulus-autocomplete'
import CharacterCounter from '@stimulus-components/character-counter'

const application = Application.start()
application.register('autocomplete', Autocomplete)
application.register('character-counter', CharacterCounter)

// Configure Stimulus development experience
application.debug = true  // trueでデバック用のログを出力
window.Stimulus   = application

export { application }
