function __sesh_connect_picker_widget
    # Jalankan lewat path eksekusi normal fish agar TUI seperti gum bisa
    # mengambil alih terminal dengan benar.
    commandline --replace 'sesh-connect-picker.sh'
    commandline -f execute
end

# Untuk default mode (emacs mode)
bind \eu __sesh_connect_picker_widget

# Untuk vi mode jika diaktifkan
bind -M insert \eu __sesh_connect_picker_widget
bind -M default \eu __sesh_connect_picker_widget
