
#let metadata = toml(".metadata.toml")
#set document(
  title: metadata.title,
  author: metadata.author,
)

#align(center, [
  // #set text(16pt)
  #heading(outlined: false, [
		#metadata.title
	])

	\

	#columns(2, [
		By

		#metadata.author

		#metadata.mail

		#colbreak()

		With

		Luleå University of Technology

		#metadata.company
	])
])

////////////////////////////////////////////////////////////////////////////////
// Preface

#set text(size: 12pt)
#set par(justify: true)
#set quote(block: true, quotes: true)
#show quote: set align(center)

#pagebreak(to: "even")
#align(center, [
	[This page intentionally left blank]
])
#pagebreak()

#heading(numbering: none, outlined: false, bookmarked: true, "Abstract")
// Offer a brief description of your thesis or dissertation and a concise summary
// of its conclusions. Be sure to describe the subject and focus of your work with
// clear details and avoid including lengthy explanations or opinions.

TODO 

*Keywords*: time series, matrix profile, anomaly detection, edge computing


#heading(numbering: none, outlined: false, bookmarked: true, "Preface")
// A preface is a statement of the author's reasons for undertaking the work and
// other personal comments that are not directly germane to the materials presented
// in other sections of the thesis.

TODO this paper and thanks

- #metadata.author, \
	Luleå University of Technology, 2025


#pagebreak()
#heading(numbering: none, outlined: false, bookmarked: true, "Glossary")

#set terms(separator: ": ")
// Introduction
/ Industry 4.0: TODO
/ Internet-of-Things: TODO
/ PLC: Programmable logic controller.
/ Edge: TODO
// Theory
/ Anomaly: An unexpected, non-conforming pattern in data.
/ Outlier: Common synonym for _anomaly_ in the context of data analysis.
/ Discord: TODO
// Method
/ Ring-buffer: A fixed-size buffer where both ends acts as if they were connected.

#pagebreak()
#heading(numbering: none, outlined: false, bookmarked: true, "Contents")
#outline(title: none, indent: 2em)

////////////////////////////////////////////////////////////////////////////////
// Introduction

#set heading(numbering: "1.")
#set page(
	numbering: "1",
  footer: context [
    #counter(page).display("1")
    #h(1fr)
    #set text(7pt)
    #metadata.author
  ]
)

#pagebreak()
= Introduction, ~3 pages <introduction>

// The introduction gives an overview of the area of your problems.

// - Increasing amount of data generated in the industry

With the shift towards Industry 4.0 @lasi, the manufacturing industries are
facing new challenges as they move towards decentralised processes.
This move is partly enabled by the advances with smart devices and the rise of
the Internet-of-Things.
By increasing the use of smart sensors a manufacturer can better supervise the
operation of their equipment and, for example, better predict equipment failure.

// - Need for fast data processing
// search: large amounts of sensor data in industry
// REFS:
// Big Data Challenges and Opportunities in the Hype of Industry 4.0

As _Khan et al._ notes @khan, sensors and PLCs are becoming the largest group
of devices that generates the most data.
And as the industries scales up their sensor networks there's an increasing need
to be able to faster process the larger amounts of data,
in order to provide real-time analysis. 

// - introduce matrix profile

This bachelor thesis will explore the use of anomaly detection on time
series data, performed on hardware-limited devices closer to the Edge.
This is an attempt at evaluating the possible usefulness of running data analysis
directly on smart sensors.
The method of anomaly detection will revolve around the Matrix Profile,
as introduced by _Yeh et al._ @yeh,
which is a family of algorithms used for detecting discord anomalies,
among other uses.
// Can't fix warnings in a quote.
They also note that "time series discords are known to be very competitive as
novelty/anomaly detectors."

The Matrix Profile is a simple algorithm with claims of being easily scaleable
@yeh and as such might offer a more performant alternative to machine learning
models or other artificial intelligence solutions that are popular as of today.
And since it doesn't require a heavy processing model, it might be able to run
on smaller devices and sensors that lacks the required processing power for
running the heavier AI models.


== Motivation

// The background offers the background to why you are working with your problems.

// - Growing sensor networks and increasing amounts of data in the industry
// search: industry 4.0
// REFS:
// Industry 4.0

Today the world is experiencing it's fourth industrial revolution.
If the use of electricity and digitisation pushed the two previous revolutions
in the manufacturing industry,
then today's shift is mainly driven by the large amount of smart, modular, and
highly connected devices that forms the so called Internet-of-Things.
Dubbed as "Industry 4.0" by the team of german scientists _Dr. Lasi et al._
@lasi,
this new revolution originated from the need of increased flexibility and better 
efficiency in production systems, in order to better handle quickly shifting
market demands.

_Dr. Lasi et al._ continues in their article with, that technology is pushing 
towards miniaturisation, digitisation, automation, and as a result,
turning today's manufacturing plants into tomorrow's "smart factories".
These factories are utilising a growing number of sensors and digital, decentralised
systems that allows the factories to become more autonomously monitored and
controlled remotely.

// - Benefits of sensor networks
// search: sensors industry 4.0
// REFS:
// Significance of sensors for industry 4.0: Roles, capabilities, and applications

_Javaid et al._ @javaid also notes an increasing need of intelligent sensor
systems and networks for the smart factories.
By using autonomous sensors with higher processing capabilities,
the industry will be able to reduce their dependency on human operators and thus
reduce problems caused by the human factor, for example. 
// Missing subject? Hard to fix passive voice
And with the availability of wireless sensors, monitoring can be done more easily
for inaccessible locations such as remote or hazardous areas.
The maintenance of the increasingly complex systems can also benefit
as more precise detection can send alerts sooner for any failing components and
thus reduce costly maintenance downtime during production.

// - Challenges with sensor networks and noisy data
// search: costs required to operate larger sensor networks???
// REFS:
// Industrial Wireless Sensor Networks: Challenges, Design Principles, and
// Technical Approaches

Of course, with increasingly larger sensor networks it also follows that there's
an increasing amount of data, as mentioned by _Javaid_.
And more raw data requires communication networks with higher processing capacity.
_Gungor et al._ @gungor suggests that the sensors should filter their data and
only send the processed data, as a step towards reducing the network overhead.
Doing so also has the possible benefit of reducing signal interference, delays,
and other anomalies, caused by faulty components or simply by the environment's
wear and tear that degrades the sensors over time.
In a later section, _Gungor_ continues with a simplified outline of a basic sensor
and notes that "... local data processing is crucial in minimizing power
consumption ...".
This has the potential of extending the lifetime of the sensors that runs on
battery, or similarly limited power sources, as well as reducing the operational
costs.

// - Application of anomaly detection to autodetect early warning signs
// search: anomaly detection temporal data
// REFS:
// Outlier Detection for Temporal Data: A Survey

Given that sensor readings are most often timestamped and thus temporal in nature
as stated by _Gupta et al._ @gupta,
the focus should be on ensuring that the time series maintains its "temporal
continuity" during the data analysis.
It should flag any sudden anomalies or other kinds of observed outliers in the
time series.


== Problem definition <definition>

This thesis looks to investigate and try to answer the following questions:

- Is it possible to run the Matrix Profile algorithm in a limited hardware
	environment, such as a small, of-the-shelf microprocessor board, and be able
	to detect anomalies in the data streams from multiple sensors?

- If so, how efficient would this on-device-detection be in terms of sent data
	traffic (or lack of) and energy use?
	The microprocessor board should have it's performance benchmarked against a
	similar board, but which sends all sensor data continuously to a remote
	controller instead.

Positive outcomes to these questions would then indicate that sensor analysis
done close to the Edge would be beneficial to the individual sensor's lifetime
and thus reduce the overall amount of spent resources required for operating
larger sensor networks.


== Delimitations

// NOTE: can fix this passive voice, missing a subject?
Due to the limited time available to write a bachelor thesis, this one will
constrain itself to only analyse the application of the Matrix Profile algorithm
for detecting anomalies, rather than comparing it to other methods which previous
surveys already have done extensively.

Also, the thesis will only explore the use of a single off-the-shelf device
such as a Raspberry Pi and a small set of simple sensors such as temperature,
humidity and light level.
Any other, more advanced devices are simply too expensive and possibly too time
consuming to work with.


== Thesis structure <structure>

The rest of the thesis has it's structure organised in the following way.
@background introduces the theory and commonly used methods for anomaly detection.
@method walks through the implementation of the Matrix Profile algorithm and
how it's applied in the hardware.
Then the section continues with the collection of data from the hardware sensors. 
@results documents and analyses the results from the data collection,
which is then discussed --  in relation to the original problem definitions --
in @discussion.

// REMARK: I've seen comments in social media about the use of dashes - in any
// form of written text - indicates the presence of "AI enhancements" or tools.
// I would like to challenge this in this last paragraph, or at least see if I
// can trap some unsuspecting fish with this bait.
// NOTE: I'm against the use of AI tools and don't use them myself!
// Instead I will cite my little handbook:
// "As a substitute for the comma, _the dash_ signals a stronger, more significant
// pause."
// - The new Oxford guide to writing, by Tomas S. Kane
// REMARK2: Although, while looking at it now it feels like a unnecessarily
// strong emphasis... But I'll leave it in anyways and see if anyone's going to
// notice.

////////////////////////////////////////////////////////////////////////////////
// Theory

// #pagebreak()
= Background and related work, ~7 pages <background>

// - anomaly detection intro
// REFS:
// @chandola Anomaly Detection: A Survey

Anomaly detection is a broad area and there exists many, detailed studies on this
subject from the last two decades @wang, @boniol.
But what is anomaly detection? _Chandola et al._ @chandola offers a definition:

#quote[
	Anomaly detection refers to the problem of ﬁnding patterns in data 
	that do not conform to expected behavior ...
	[which] translate to signiﬁcant, and often critical, actionable
	information in a wide variety of application domains.
]

Being able to find these non-conforming behaviours and patterns in all kinds of
data is useful indeed.
Any applicable context that have some kind of continuously, periodic data readings
involved can benefit from anomaly monitoring and detection,
to prevent problems cropping up in the future.


== Applications and challenges

Let's illustrate with a few example applications that are commonly used in the
literature @chandola, @gupta:

- Network intrusion:
	A network and it's local resources such as servers, data repositories and even
	users, can have it's traffic monitored to prevent the unauthorised use of or
	access to critical components such as private data or administrator users.
	Common problems in this domain involves being able to handle the large amount
	of streaming data generated from, for example, data traffic that can cause
	false alarms.
	
- Fraud detection:
	Here the goal is to detect any criminal activities from users that are looking
	for ways to fraudulently collect any resources with economical benefits,
	from other users or companies such as banks or insurance agencies.
	For example, sudden bank transfers made by an individual inside a company could
	look like an anomalous pattern from their normal behaviour,
	indicating a potential insider trader, and analysis should flag it as such.
	
- Medical and public health monitors:
	Medical symptoms or diseases can be detected and tracked by using medical data,
	either from patient records or attached health sensors.
	For example, it's common to monitor a patient's condition over time
	or tracking the outbreak of diseases in specific areas such as cities.
	In this scenario, not being able to detect anomalies in the patient's data could
	have fatal results.

- Industrial damage monitoring and sensor networks:
	Monitoring the wear and tear on industrial equipment allows for taking preventive
	action that can minimise the costs of service interruptions or equipment failures.
	Most often this requires running analysis on online, streaming data from sensor
	networks, for example, in order to detect the anomalies in a quicker manner.

// Challenges with anomaly detection

But detecting non-conforming patterns in data is a difficult problem.
_Chandola_ have also noted a set of challenges associated with classifying any
observed patterns:

- It's hard to distinguish noise in the data from true anomalies, as they can
	show similar-looking patterns.
- It's hard to draw a clear boundary between what's a normal or anomalous pattern,
	while covering all possible normal cases.
- A set of patterns considered as normal behaviour at the present time can fail
	to cover any future patterns, due to evolving conditions.
- Different application domains have different anomalous patterns and thus it's
	not easy to apply a single set of normal patterns on multiple domains.

_Gupta et al._ @gupta notes a few more challenges:

- The scale of the data can be large in streaming data scenarios, thus requiring
	better processing capacity.
- Distributed scenarios requires more communication and thus also requires better
	processing capacity.
- Are there any data available with examples of anomalies, which an analysis model
	can train on?

These challenges then most often result in specific solutions for
finding anomalies in a single domain.
It has previously been common to use various kinds of machine learning models,
for example:
neural networks, support vector machines (a linear classification model),
decision trees (a rules-based prediction model),
k-nearest neighbour (a distance based model), 
DBSCAN (a clustering model),
or any mix of multiple models.
But these models have shared problems of requiring extensive training data before
being able to run data analysis, which might require human supervision.
The models could also be too computation heavy for running in
resource-constrained environments, such as small devices and sensors.


== Types of anomalies

// - types of anomalies
// REFS:
// Revisiting Time Series Outlier Detection: Deﬁnitions and Benchmarks

Yet another challenge is how to define what is an anomalous pattern.
Most often it's some kind of outlier that clearly differentiates itself from
the other data, but it could also be more subtle issues that's harder to spot.
A definition that is commonly used in the literature @chandola, @gupta
and summarised by _Lai et al._ @lai:

- Point anomalies:
	Individual data points with extreme values that make them stand out
	from all other points in the data.
	These are the most simplest to detect and have been the largest focus in
	previous research.

- Contextual anomalies:
	These are also individual data points, but with values that make them stand out
	in the local context --
	which needs to be defined during the analysis --
	instead of globally.
	It's considered a harder problem to identify this kind of anomaly.

// NOTE: About the use of dashes in text, see the comments in @structure
// (around line 295, up and above).

- Collective anomalies:
	This is a subsequence of data points, which individually might not stand out
	but as a group they could differentiate themselves from the rest of the data,
	globally.

// - define discord anomalies

_Lai_ illustrated these anomalies nicely in @anomalies, shown below. 
To save time, this thesis will be limited to a group of collective anomalies
referred to as *discords*, which _Yeh et al._ @yeh defines as "the subsequence
that has the maximum distance to its nearest neighbor.",
which the following section will be expanding upon.

#figure(
	image("images/standard_anomalies.png", width: 100%),
	caption: [
		Examples of anomalies in time series data @lai. \
		Left = point, middle = contextual, right = collective.
	]
) <anomalies>


== Detecting discord anomalies

// - discord detection using MP

_Yeh_ introduced a novel algorithm called the _Matrix Profile_ in their paper @yeh,
as a new alternative for finding data anomalies.
The Matrix Profile produces a form of metadata array that, in simplified terms,
represents the minimal Euclidean distances between each subsequence, of size _m_,
in the analysed time series _ts_.
The paper contains a more in-depth examination of the details and definitions,
which is not repeated here for brevity.

A useful property of this new metadata is that the higher values in the array
indicates discord anomalies in the time series data, as demonstrated in @mpexample.

#figure(
	image("images/mp_example.png", width: 90%),
	caption: [
		A plotted ECG (top) with accompanying Matrix Profile (bottom). \
		Note that the highest peak of the MP coincides with the PVC @yeh.
	]
) <mpexample>

This example illustrates a scenario where point or contextual anomalies can be
common and even normal behaviour,
and it's more useful to watch for collective anomalies instead.
It also highlights the difficulty of finding anomalies directly in raw data,
with jitter-ish or noisy values.
What's also noteworthy is that the detected anomaly coincides exactly with the
beginning of the pattern in the raw data readings, as commented by _Yeh_.


== Discord Aware Matrix Profile

// - the DAMP algo, an alternative to MP

TODO: higher distance score similarity means the subsequence pattern is atypical
and there is no similar subsequence in the data

Also known as DAMP, this is a new, alternative implementation of the Matrix
Profile by _Lu et al._ @lu, with a focus on discovering discord anomalies in
large scales of either batched or streaming data.
_Lu_ achieves this higher performance by calculating an approximate Matrix Profile
from each subsequence's distance to all previous ones only, in a backwards
processing manner.

TODO: time and space complexities

@machining shows an example profile based on sensor data from a milling machine.
In this example it's harder to observe, by eyes only, the beginning of the
anomalous pattern.
More importantly, detection needs to be fast enough to stop the milling process
sooner and avoid damaging the equipment.

#figure(
	image("images/machining_plot.png"),
	caption: [
		Readings @lu from a vibration sensor attached to a milling machine (above)
		during 3 minutes. 
		Near the end the machine starts cutting into other parts of the equipment,
		as indicated by the tallest discord peak in the profile (bottom).
	]
) <machining>

// TODO: mention is based first on paper algo, then matlab example and lastly own code???

// TODO: probably have to explain why splitting data into training/testing

@dampalgo shows pseudo code for the DAMP algorithm.
The function takes as input a time series _ts_, a subsequence length _m_ and
a split index _s_ which marks the split between training and testing data in the
time series. 
The empty array _amp_ created on line 02 contains the approximate Matrix Profile
and _bsf_ tracks the highest distances during the process.
The first loop starting on line 06 finds an initial value for _bsf_, by using the
MASS function to calculate a first set of distance profiles.
_Zhong et al._  @mueen created this function and it's shown later in @massv2.

TODO: explain that first loop is the training phase

// Adds zero-padded line numbers to code blocks
#show raw.line: it => {
	let no = str(it.number)
	let pad = str(it.count).len() - no.len()
	text(fill: gray)[#{
		pad * "0" + no
	}]
	h(0.5em)
	it.body
}

TODO: SIMPLIFY to english pseudo code

#figure(```go
func DAMP(ts []float, m int, s int):
	amp = make([]float, length(ts))
	bsf = -inf

	// Find highest distance profile from the first chunk of data
	for i = from (s - 1) to (s + 16*m):
		query = ts[i : i + m]
		amp[i] = min(massv2(ts[ : i], query))
	bsf = max(amp)

	// Continue looking for higher distance profiles in the following data
	for i = from (s + 16*m) to (length(ts) - m + 1):
		amp[i], bsf = processBackward(ts, m, i, bsf)

	return amp
```, caption: [The DAMP algorithm.]) <dampalgo>

// - helper func backwardProcess

The second loop on line 12 then iterates through all subsequences in the time
series and calculates their distance profiles using the _processBackward_ function,
shown in @backproc.
This function finds the highest distance profiles by working backwards in an
expanding search (done on lines 22-23) from the current subsequence,
starting in the loop on line 07.
To prevent reading non-existing data, the process has to consider the two special
cases on line 12 and line 18 which guards against reading data past either
possible end of the time series.

#figure(```go
func processBackward(ts []float, m int, i int, bsf float):
	ampi = +inf
	size = nextpower2(8*m)
	exp = 0
	query = ts[i : i + m]

	while ampi >= bsf:
		start = i - size + exp*m + 1
		stop = i - size/2 + exp*m + 1

		// Case 1: the segment furthest from the current subsequence
		if start < 1:
			ampi = min(massv2(ts[0 : i + 1], query))
			if ampi > bsf: bsf = ampi
			break loop

		// Case 2: the segment closest to current 
		if exp == 0: stop = i + 1

		// Get current distance profile and expand the search (if needed)
		ampi = min(massv2(ts[start : stop], query))
		size = size*2
		exp = exp + 1
	return ampi, bsf
```, caption: [DAMP backward processing.]) <backproc>

By halting the search as soon as a distance score is lower than the best so far
value _bsf_, the algorithm also solves the "twin-freak" problem.
An anomaly will cancel out itself if it appears more than once, hence the name,
as the nearest neighbour will be itself during the calculations of the distance
profiles.

// - helper func MASS v2, nearest neighbour search

Finally, @massv2 displays the MASS function for the sake of completeness.
The core part is the use of Fast Fourier Transforms @fft,
enabling efficient distance calculations.

#figure(```go
func massv2(x []float, y []float):
	m, n = length(y), length(x)
	meany, meanx = mean(y), movmean(x, m - 1, 0)
	sigmay, sigmax = std(y), movstd(x, m - 1, 0)

	// Reverse query and append zeroes until equal size as x
	y = reverse(y)
	y[m + 1 : n] = zeroes

	// Calculate dot products in O(n log n) time
	fx, fy = fft(x), fft(y)
	fz = fx*fy
	z = ifft(fz)

	// Calculate the distance profile and return array
  dist = 2*(m - (z(m:n)-m*meany*meanx(m:n)) / (sigmay*sigmax(m:n)) )
	return sqrt(dist) // As a []float
```, caption: [The MASS v2 distance profile calculation.]) <massv2>

It's also noteworthy that this function operates more efficient if the amount of
data points is a power of two, as mentioned by _Lu_ @lu.
If it's not, the MASS function would be hit with a hefty performance drop.
The DAMP algorithm avoids this, on line 03 in @backproc, by setting the size
of the processed data to the next power of two that is after the subsequence
size _m_.

For the sake of brevity, the MASS function is not examined any further.


////////////////////////////////////////////////////////////////////////////////
// Method

#pagebreak()
= Method, ~8 pages <method>

// - running matlab reference and gathering ref. data

_Lu et al._ have provided an example of their DAMP algorithm in the form of a
Matlab file, as a complement to their paper @lu.
Running that example produced the data used for creating the plot in @machining,
as shown previously.
Both the raw in-data and the output Matrix Profile data was then saved as a
reference dataset, used for verifying future implementations.
The appendix in @appendixrepo has a link to the repository that stores this dataset.

// - implement original algo and verify it against ref.
With reference data available, the original DAMP algorithm was then implemented
in Go @go as outlined in @dampalgo and @backproc.
Go is famously known for it's simple syntax and large standard library,
which lends itself well to the purpose of making quick but production-ready prototypes.
This, along with this author's previous experiences and familiarity, was the reason
for selecting Go for the practical aspects of this thesis and provides both
a stable environment and an alternative to Matlab.

The Go implementation also includes a complementary test suite which verifies,
against the reference data, the correctness of the implemented algorithm.
@results will later go into details of these results and provide an expanded analysis.


== Adapting the algorithm

// - adapt algo to streaming data using ring buffer

As @introduction previously mentioned, the DAMP algorithm should run in a live
scenario and be able to handle live sensor data.
The original algorithm would produce a Matrix Profile contained in a data array
that is of equal size as the in-data, so appending new in-data would then grow
the output array.
Eventually the computer would either run out of memory, when it fills up with
the arrays, or reprocessing the increasingly larger in-data array would consume
too much time and energy to be of any practical use in a live scenario.

In order to handle this scenario, the Go implementation must be adapted to handle
continuously arriving data without running out of computing resources.
_Lan et al._ suggests @lan, as a basic strategy, to use a cache of any sort and
limit the amount of data processed.

_Gillis_ offers a simple to use double-ended queue in Go @gillis and it can
operate as an efficient ring-buffer.
@deque illustrates the queue and it's worth noting that it operates in $O(1)$ time
when pushing or popping from either end.
The internal buffer is always a power of two too, so this queue fits in nicely
with the use of the previously mentioned MASS function and its operation requirements.

#figure(
	image("images/deque.png"),
	caption: [Double-ended queue by _Gillis_ @gillis, operating as a ring-buffer.],
) <deque>

By using this new data structure in place of the previously used data arrays and
making adaptations to the DAMP algorithm, an alternative implementation could
then process the continuously streaming data from the hardware sensors.

TODO: rewrite into plain english and explain details in a paragraph or two

#figure(```go
func (a *StreamingDAMP) Push(v float64) float64:
	if a.data.Len() == a.maxSize:
		a.data.Pop()
		a.amp.Pop()
		if a.index > -1:
			a.index--
			if a.index < 0:
				// Drops the score once in-data value is popped from the buffer
				a.bsf, a.index = a.amp.Max()

	a.data.Push(v)
	tlen = a.data.Len()
	if tlen < a.trainSize:
		// Keep waiting for more training data
		a.amp.Push(0)
		return 0

	val, index, bsf = processBackward(a.data, a.seqSize, tlen-a.seqSize, a.bsf)

	if math.IsNaN(val):
		// This happens when there's constant regions in the data
		val = 0

	if bsf > a.bsf:
		a.bsf = bsf
		a.index = index

	a.amp.Push(val)
	return val
```, caption: [The DAMP algorithm adapted to handle streaming data.]) <streamdamp>


== Setting up hardware environment

Running the adapted DAMP algorithm in a live-test scenario requires the setup of
a hardware environment.
This thesis uses cheap, consumer-grade devices that can be commonly found
off-the-shelf and the bill of materials includes:

TODO: needs links/refs?

- *Raspberry Pi 4, model B with 1GB RAM.* \
	It's versatile enough and allows for running high-level programming languages,
	thus not restricting the user to work with closer-to-the-metal environments such
	as with assembly or plain C programming. Saves a great amount of time.

- *Environment Sensor HAT, by Waveshare.* \
	This is an addon module equipped with a TSL25911 ambient light sensor, a BME280
	temperature, humidity, and air pressure combination sensor, a ICM20948 gyroscopic
	motion sensor, an LTR390-UV-1 uv sensor, and finally a SGP40 volatile organic
	compound sensor. Provides many alternative sensors in a single package.

- *IQaudio Codec Zero, by Raspberry Pi.* \
	TODO: couldn't get it to work even?? remove altogether?


=== Setup
- download image from:

    https://www.raspberrypi.com/software/operating-systems/

- verify downloaded image wasn't corrupted:

    `sha256sum <img name>.sha`

- decompress:

    `unxz <img name>.xz`

- and then flash the image to a SD card:

    `dd if=<img name> of=/dev/<device> bs=1M`

- now boot the raspberry and follow it's first time setup and create a user.

- Connect to wifi using networkmanager, https://wiki.debian.org/NetworkManager

- First create the new connection:

    `sudo nmtui`

- if wifi SSID is hidden, must force active the connection:

    `sudo nmcli connection up <network>`

- with internet available, fetch and install updates:

		`sudo apt update && sudo apt upgrade`

// - setting up influx and logging sensor data

- finally install influxdb, see appendix XXX for install instructions.

- once influx is installed, open URL and follow in-browser setup and done.

== Logging sensor data

// - applying streaming algo to live sensors
// - gyro didn't work out, had constant regions
// - constant regions causing NaNs and had to add region check, ignored in streaming algo

// EXTRA:
// - hardware setup
// - collecting sensor data
// - power monitoring
// - handling normalisation issues?
// - damp paper suggest learning threshold values for the scores

////////////////////////////////////////////////////////////////////////////////
// Results

// The evaluation evaluates whether you have actually solved your problems.

#pagebreak()
= Results, ~10 pages <results>

TODO

#figure(
	image("damp/1-bourkestreetmall-plots.png", width: 80%),
	caption: [test],
)

#figure(
	image("damp/2-machining-plots.png", width: 80%),
	caption: [test],
)
== Analysis

TODO

- algo too heavy for raspberry pi (and 4 sensors)
- surprised that the ring-buffer didn't affect performance

////////////////////////////////////////////////////////////////////////////////
// Discussion

// The discussion discusses each individual problem, how you addressed it, alternative solutions and shortcomings, etc.

// #pagebreak()
= Discussion <discussion>

TODO

hard to work with matlab code examples:
- one-based indexing (instead of the more common zero indexing) causing many issues
	and off-by-one errors.
- large amount of helper funcs required for performing arithmetic on arrays.
- doing a fast fourier transform required the use of complex numbers, which was
	a different type in Go and might cause performance problems.

algo:
- can't handle constant regions, causing NaNs.
- especially gyro worked poorly, as it kept to it's baseline all the time.
- but one happy accident was that the new streaming algo could recover from the
	constant region problems thanks to the ring-buffer cycling through data.
- surprised the deque library didn't add bad performance overhead.
- hard to pick good seq.size, need more research and detailing effects of it.

sensors:
- the choice of hardware sensors was poorly made, should had researched better.


////////////////////////////////////////////////////////////////////////////////
// Conclusion

// The conclusions and future work describes the final outcome of how you solved your problems and what is left to do.

== Conclusion

TODO

== Future work

TODO

- research the effects of different seq. sizes.
- need more applications in real scenarios.

////////////////////////////////////////////////////////////////////////////////
// References

#pagebreak()
= References

#bibliography(
	"references.yml",
	style: "ieee",
	title: none,
)

////////////////////////////////////////////////////////////////////////////////
// Appendices

#pagebreak()
= Appendix A <appendixrepo>

TODO: link to repo and any other instructions

#pagebreak()
= Appendix B <appendixb>

TODO: source for algo implementation?

#figure(
	raw(read("damp/damp.go"), lang: "go", block: true),
	caption: "testing",
)
