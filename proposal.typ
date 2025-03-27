
#set text(size: 10pt)
#set page(numbering: "1")

// Add inline bibliography
#let bibitem(body) = figure(kind: "bibitem", body, supplement: none)
// Display the list of references.
#show figure.where(kind: "bibitem"): it => {
	align(left,
		box(width: 2em, it.counter.display("[1]")) + it.body + parbreak()
	)
}
// Display citation
#show ref: it => {
	let e = it.element
	if e != none and e.func() == figure and e.kind == "bibitem" {
		// Display a citation
		numbering("[1]", ..e.counter.at(e.location()))
	} else {
		it // Displays the original reference
	}
}

#align(center, [
	= B.Sc. thesis proposal: \ Time series anomaly detection for edge computing

	\

	#columns(2, [
		By

		Alex TODO

		`mail@mail`

		#colbreak()

		With

		Luleå University of Technology

		company xxx
	])
])

////////////////////////////////////////////////////////////////////////////////

= Introduction

There exists multiple methods for detecting anomalous patterns in time series data.
These methods commonly relies on @methods statistical analysis, machine learning,
or signal processing for example.
But in 2016, a new algorithm called "matrix profile" was published with
claims that it's simpler, more efficient, and easily scalable @matrix.

I would like to investigate this new method, apply it in a physical scenario using
of-the-shelf devices and measure it's effectiveness.


= Motivation

If the matrix profile could be used in industry sensors or other kinds of edge computing
devices, it might be possible to reduce the amount of stored data, sent traffic,
and the overall energy usage.
The sensors would only need to start sending their data to a central controller,
once the sensors themselves discover any anomalies in their own readings.
And by reducing the energy usage in sensor networks, any industry should be able to
save on some amount of their resources and thus reduce their climate footprints, for example.


= Problem description

With this project, I would like to investigate and try to answer the following questions:

- Using a small device equipped with a microprocessor and a simple sensor,
  is it possible to apply the matrix profile on the sensor's data readings and
  detect anomalies directly on the device?

- What type of anomalies can be detected?

- Comparing the first device with a similar one that is not running matrix profiling,
  how efficient is the first device in terms of energy use, sent data traffic,
  and CPU utilisation?


= Solution method

An Arduino Uno
#footnote[https://docs.arduino.cc/hardware/uno-rev3/#tech-specs]
board running a simple ATmega processor, with a single photoresistor
connected to it, is able to measure the level of light of the environment.
The light will slowly fluctuate over time and from local weather, and it's easy
enough to cause temporary anomalies by simply covering the photoresistor or putting
it under some extra light source.
The board should be good enough to run the matrix profile, which needs to be implemented
in the C language.
Built-in functions can be used to measure the execution time or CPU utilisation
when running the code on the board.
If the board isn't powerful enough to run the code, a Raspberry Pi could be used instead.

Investigation must be done to determine if there's already built-in
tools for measuring the board's energy usage. Alternatively, the incoming power source
could be measured directly by using an external voltage sensor.
The voltage sensor can then be connected to the controller, which stores the energy readings.

Additional investigation is needed to determine how to send the sensor data using
Bluetooth, wifi or a direct serial line to a central controller.
The controller itself can be a full Raspberry Pi or a laptop, which will store and
display the collected sensor data as a series of graphs and other statistics,
using the InfluxDB time series database.
//The statistics can then be used to measure the effectiveness and be compared with
//similar data from a second board, that is not running matrix profile.


= Expected outcomes

The first board running matrix profile should be able to identify and send a
warning whenever it discovers an anomaly in the sensor data from the photoresistor.
The warnings must be stored on the controller, along with the other sensor data.

Using the full sensor data from the second board, the controller should run an alternative,
pre-built implementation or framework of matrix profile.
It should be able to
find similar
anomalies and warnings as the first board. This will prove that the C implementation
was done correctly.

Finally, by using the statistics collected in InfluxDB it will be possible to measure
the energy effectiveness and do a comparison between both Arduino boards.
Hopefully, the board running matrix profile will have a lower energy usage
(despite running more code) as it needs to send less data and use the wireless
connection to a lesser extent.


= Supervision

External supervisor at SysPartner:

- company person (`peron@company`)

Internal supervisor at LTU:

- Undecided

= Time plan

- Week 1: Find and study previous work done, run reference implementation (done in Python, for example) on artificial data.
- Week 2: Setup the first board, start developing C implementation of matrix profile.
- Week 3: Finish implementation and test it on the board.
- Week 4: Investigate and implement sending data wirelessly (preferable) from the board.
- Week 5: Investigate how to measure energy usage, setup extra sensors if required.
- Week 6: Finish both investigations and apply new implementations on the board.
- Week 7: Setup controller and InfluxDB, start collecting sensor data and energy usage.
- Week 8: Setup second board without matrix profile, let it send full sensor data and start analysing the statistics.
- Week 9: Finish the analysis and comparison of both boards, write up the results.
- Week 10: Intentional left as a spare, in case of problems.


////////////////////////////////////////////////////////////////////////////////

= References

#bibitem[
	Neri Van Otten,
	_Top 8 Most Useful Anomaly Detection Algorithms For Time Series And Common Libraries For Implementation_,
	2023-03-18,
	https://spotintelligence.com/2023/03/18/anomaly-detection-for-time-series/
] <methods>

#bibitem[
	Eamonn Keogh,
	_The UCR Matrix Profile Page_,
	undated,
	https://www.cs.ucr.edu/~eamonn/MatrixProfile.html
] <matrix>

