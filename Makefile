install:
	install -D -m 0755 -v actions.sh ${HOME}/.local/bin/isdc-cli
	install -D -m 0755 -v singularity-osa.sh ${HOME}/.local/bin/isdc-singularity
	install -D -m 0755 -v autocomplete.bash ${HOME}/.bash_completion.d/isdc-cli.bash
	install -D -m 0400 -v README.md ${HOME}/.local/share/doc/isdc-cli.md
	< $(HOME)/.bash_completion grep isdc-cli.bash || echo 'source $$HOME/.bash_completion.d/isdc-cli.bash' >> $(HOME)/.bash_completion

test:
	./actions.sh test-all
