
# Data samples

This dir contains the datasets that's being used for testing discord detection
using the DAMP algorithm.

Datasets:

- 1-bourkestreetmall:
  This was a dataset provided with the reference implementation of DAMP,
  done in Matlab. \
  "The City of Melbourne, Australia has developed an automated pedestrian counting
  system to better understand pedestrian activity within the municipality,
  such as how people use different city locations at different time of the day." \
  Sources:
  - https://sites.google.com/view/discord-aware-matrix-profile/documentation#h.x0wxaf36mrac
  - https://timeseriesclassification.com/description.php?Dataset=MelbournePedestrian \
  Status:
  The prototype successfully reproduced the results from the reference implementation.

- 2-machining:
  Another dataset used in the paper, about 2.5 times larger than the previous.
  This set might be better for benchmarking, but the original source is unknown. \
  Source:
  https://sites.google.com/view/discord-aware-matrix-profile/dataset#h.7b6qriohcyr2 \
  Status:
  The prototype successfully reproduced the results from the reference implementation,
  although with lesser precision.

- Knutstorp-tonga:
  TODO
  Source:
  - https://www2.irf.se//weather/
