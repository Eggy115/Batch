
md "\\tamp20pvfiler09\share1\Hills_IT_images\admin\Bit Locker\%computername%"

manage-bde -tpm -t
manage-bde -tpm -o
manage-bde -on C: -rp -rk "\\tamp20pvfiler09\share1\Hills_IT_images\admin\Bit Locker\%computername%" -s > "\\tamp20pvfiler09\share1\Hills_IT_images\admin\Bit Locker\%computername%\%computername%.txt"

Pause