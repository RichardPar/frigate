BOARDS += vim4

local-vim4: version
	docker buildx bake --file=docker/vim4/vim4.hcl vim4 \
		--set vim4.tags=frigate:latest-vim4 \
		--load

build-vim4: version
	docker buildx bake --file=docker/vim4/vim4.hcl vim4 \
		--set vim4.tags=$(IMAGE_REPO):${GITHUB_REF_NAME}-$(COMMIT_HASH)-vim4

push-vim4: build-vim4
	docker buildx bake --file=docker/vim4/vim4.hcl vim4 \
		--set vim4.tags=$(IMAGE_REPO):${GITHUB_REF_NAME}-$(COMMIT_HASH)-vim4 \
		--push
