#! /bin/bash

terraform graph | dot -Tpng > terraform_graph.png
