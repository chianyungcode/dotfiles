if initialize_session "backend"; then

  # Create a new window inline within session layout definition.
  #new_window "misc"
  load_window "backend"
  # Load a defined window layout.
  #load_window "example"

  # Select the default active window on session creation.
  #select_window 1

fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
