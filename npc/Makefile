all:
	@echo "Write this Makefile by your self."

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	verilator --cc --exe --build -j 0 -Wall ./csrc/main.cpp ./vsrc/example.v
	./obj_dir/Vexample

include ../Makefile
