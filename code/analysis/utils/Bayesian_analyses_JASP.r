
# R-code to recreate the Bayesian analyses performed in JASP for our manuscript "Working memory signals in early visual cortex do not depend on visual imagery" by Weber, Christophel, Görgen, Soch, Haynes.
# Data is stored in "data-export.csv"

# Bayesian t-test for behavioral precision btw. weak and strong imagers.
# BF01 is selected to evaluate the likelihood of observing the data under the null hypothesis.
jaspTTests::TTestBayesianIndependentSamples(
          version = "0.17.1",
          formula =  ~ Behavior,
          bayesFactorType = "BF01",
          bfRobustnessPlot = TRUE,
          group = "Strong")


# Bayesian t-test to evaluate the likelihood that there might be a strong>weak effect in the delay-period target reconstruction (i.e., our initial hypothesis).
# BF01 is selected to evaluate the likelihood of observing the data under the null hypothesis.
jaspTTests::TTestBayesianIndependentSamples(
          version = "0.17.1",
          formula =  ~ BFCA target,
          alternative = "less",
          bayesFactorType = "BF01",
          bfRobustnessPlot = TRUE,
          group = "Strong")

# Bayesian correlation analysis to evaluate the likelihood to observe the data given a positive correlation between delay-period target reconstruction and VVIQ scores.
# BF01 is selected to evaluate the likelihood of observing the data under the null hypothesis.
jaspRegression::CorrelationBayesian(
          version = "0.17.1",
          alternative = "greater",
          bayesFactorType = "BF01",
          variables = list("BFCA target", "VVIQ pre"))
