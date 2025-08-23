.DEFAULT_GOAL := commands

ifeq ($(OS), Windows_NT)
  COMMIT = @git status --porcelain | findstr /R "^ M ^A ^D ^R ^C ^UU ^??" >nul && \
  (git add . && git commit -m "Update") || @echo No commits to make.
else
  COMMIT = @git status --porcelain | grep -q "^\( M\|M \|A \|D \|R \|C \|UU \|?? \)" && \
  (git add . && git commit -m "Update") || @echo No commits to make.
endif

commands:
	@echo Commands:
	@echo     make commit ---------- Branch commit (using git)
	@echo     make push ------------ Push your project for repository
	@echo ----------------------------------------------------------
	@echo     (c) 2025 - William Canin - Makefile commands

build:
	@makepkg -sf

install:
	@sudo pacman -U firewall-*.zst

commit:
	$(COMMIT)

push: commit
	@git push -u origin
	@git push -u lab
	@git push -u hub
