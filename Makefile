.PHONY: setup
setup:
	@flutter clean
	@flutter pub get

.PHONY: pigeon
pigeon:
	@dart run pigeon --input pigeons/api.dart