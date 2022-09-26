# This is a script which walks you through basic ggplotting (in part A.)
# It is not giving you good advice for Visual Communication, just the technicalities with 
# the Grammar of Graphics.
# Later (in part B.) it very briefly introduces data wrangling with dplyr and piping 

# We need the tidyverse packages
library(tidyverse)

# A. How does a ggplot graphic work?
#
# We use the mpg dataset which is in the ggplot library
# Let us take a brief look into its variables and their meaning
glimpse(mpg)
?mpg

# This is the first plot in a basic specification
# We take cty = "city miles per gallon" as x and hwy = "highway miles per gallon" as y
ggplot(data = mpg) + geom_point(mapping = aes(x = cty, y = hwy))
# Compare to "The complete template" from the cheat sheet 
# https://raw.githubusercontent.com/rstudio/cheatsheets/main/data-visualization.pdf
# It has all the required elements.
# We specify the data in the ggplot command, and the aesthetics (what variable is x and what variable is y)
# as mapping in the geom-function geom_point 

# If you look at the function documentation of geom_point, you see that it also requires "data ="
?geom_point
# The ggplot-line above has no specification of data in geom_point?
# However, the "+" in ggplot specifies that specifications will be taken from the object defined before the +.
# Technically ggplot() creates an ggplot object (the graphic) and +geom_point() adds more information to it.
# So, the data was be taken from the ggplot call. 
# Note, that it also works this way
ggplot() + geom_point(data = mpg, mapping = aes(x = cty, y = hwy)) # Same as before ...
# But also this way
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + geom_point() # Same as before ...
# The latter is the most common way. In principle, we can specify new data and aesthetics in each geom-function
# and sometimes this makes sense. Usually, we only have one dataset and one specification of aesthetics

# As common practice we can shorten the code and remove the "data = " and the "mapping = " 
# because the first argument will be taken as data (if not specified otherwise) and the second
# as mapping (if not specified otherwise) see function documentation
?ggplot
# So, the common short form is 
ggplot(mpg, aes(x = cty, y = hwy)) + geom_point() # Same as before ...

# But we can even remove the "x = " and "y = " if we look at the specification of aes()
?aes
# So, even shorter
ggplot(mpg, aes(cty, hwy)) + geom_point() # Same as before ...

# QUIZ: Do the following 7 lines work? If not, why not? If yes, why?
ggplot(aes(x = cty, y = hwy), mpg) + geom_point()
ggplot(aes(x = cty, y = hwy), data = mpg) + geom_point()
ggplot(mapping = aes(x = cty, y = hwy)) + geom_point(mpg)
ggplot() + geom_point(aes(x = cty, y = hwy))
ggplot(mpg,aes(cty, hwy)) + geom_point()
ggplot(mpg,aes(hwy, cty)) + geom_point()  # Is identical to the above?
ggplot(mpg,aes(y = hwy, x = cty)) + geom_point()  # Is identical to the above?


# There are more aesthetics, like color, shape, size, and fill. However these need to be specified and 
# cannot be left out. Let us color the manufacturer, and make size by cylinders
ggplot(mpg, aes(cty, hwy, color = manufacturer, size = cyl)) + geom_point()

# What do we see now in our graph? Some problems are:
# 1. There many manufacturers probably much more than the human eye can distinguish colors properly. 
# So, the graphic cannot serve users to really read information about manufacturers
# 2. Cylinder is mapped to size but the dots for "4" are much smaller than for "5", "6", "7". 
# This does not look proportional. But even when it were it is not idealy to clealy distinguish what is what. 
# At least it can communication the larger the more cylinders...
# 3. It seems like that many dots may be at the same location so the whole plot may suffer 
# from substantial overplotting! Maybe the whole type of geom-function geom_point is not that well chosen?
# 
# These three problems are all not technical problems of ggplot. The grammar of graphics works fine. 
# These are problems of EFFECTIVE/APPROPRIATE VISUALIZATION or more general, problems of 
# VISUAL COMMUNICATION. Becoming more proficient in the solution of these will be a core topic in the next weeks!

# Btw, this makes the area of the dots proportional to the underlying value (cylinders)
ggplot(mpg, aes(cty, hwy, color = manufacturer, size = cyl)) + geom_point() +
  scale_size_area()
# Btw, with geom_jitter every point is moved a bit at random and we may get a hunch from that 
# about how much overplotting there is
ggplot(mpg, aes(cty, hwy)) + geom_point() + geom_jitter(color = "green")

# Note, in the last call we did two new things:
# 1. We added another geom-function to an existing one. That is a core idea of the grammar of graphics.
# However, for a final version, we would probably not do geom_point together with geom_jitter.
# A typical example would be to add a summary statistic like geom_smooth
ggplot(mpg, aes(cty, hwy)) + geom_point() + geom_smooth()
# 2. We specified a color of points by name, the "red" dots in the geom_jitter. What is the difference to the 
# specification "color = manufacturer" before? The latter happened with an aes()-function and thus it maps  
# the variable values to different colors. This would not work outside of an aes()-function
ggplot(mpg, aes(cty, hwy)) + geom_point(color = manufacturer) # Throws an error!
# It would work as 
ggplot(mpg, aes(cty, hwy)) + geom_point(aes(color = manufacturer))
# Even more confusing can things like this be:
ggplot(mpg, aes(cty, hwy, color = "green")) + geom_point() # Shows dots supposed to be "green" in red?
# This is because "green" is taken here as the one an only variable value for all data points, and the color
# for this value is chosen by ggplot as redish by default.
# Correct in making dots green would be this
ggplot(mpg, aes(cty, hwy)) + geom_point(color = "green")

# Now we should consider again that ggplot() calls create an object, and we can assign it a name
our_plot <- ggplot(mpg, aes(cty, hwy)) + geom_point(aes(color = manufacturer))
# If we call this there is no output, but the graphic information is stored in the object our_plot
# As with other objects, when we write it in the console as such it provides an answer. In the case of 
# ggplot-objects the answer is not some printed text in the console but an output in the Viewer pane or similar
# (it may depend on your RStudio specification)
our_plot

# Such ggplot objects can be further altered by more "+...". For example
our_plot + geom_smooth()

# Following "The complete template" from the cheat sheet 
# https://raw.githubusercontent.com/rstudio/cheatsheets/main/data-visualization.pdf
# The next optional things to specify a ggplot-object are to 
# a. maybe do somethings with the coordinate system
our_plot + coord_flip() # flip x and y
our_plot + coord_polar() # weird here but useful for some things
# b. Do faceting based on another variable in the data
our_plot + facet_wrap("manufacturer")
our_plot + facet_grid(cyl ~ fl) # fl is the fuel type
# c. Do things with the scales of the various aesthetics
our_plot + scale_x_log10()
our_plot + scale_x_log10() + scale_y_reverse()
our_plot + scale_colour_hue(l = 70, c = 30)
# This includes axis limits and labeling
our_plot + xlim(c(0,40)) + 
  xlab("City miles per gallon") + ylab("Highway miles per gallon")
# d. Choose or modify themes
our_plot + theme_bw()
our_plot + theme_void()
our_plot + theme_dark()




# B. Data wrangling with dplyr and the pipe |>

# Often you need to do some modifications (cleaning, tidying, filtering, resizing, new variables,...) 
# with the data before plotting. This is called data wrangling and is done with the packages
# dplyr and tidyr
# Steps of data wrangling are often done one after the other using the pipe |>
# This is just a very short intro how a typical line looks. 

mpg |> filter(manufacturer == "audi") # This shall filter such that only the audi's remain in the dataset
# What is the pipe doing? 
# It takes the output of what is before the pipe (here `mpg`) and puts it as the first argument of the 
# function call behind the pipe (here the `filter(...)`).
# That means the line above is identical to 
filter(mpg, manufacturer == "audi")
# This works with all functions. You can do
c(2,3) |> sum()
# Which is the same as
sum(c(2,3))
# Or as the beginning of a quick visualization
mpg |> ggplot(aes(cty, hwy)) + geom_point()

# Why do we use piping? Let us look at the following line 
mpg |> 
  filter(manufacturer == "audi") |> # This we had already
  select(model, cty, hwy) |> # This selects only these three variables and removes the others
  mutate(avg = (cty + hwy)/2) |> # This computes the average of cty and hwy
  ggplot(aes(model,avg)) + geom_point() # This does a plot
# Without using the pipe this call would be 
ggplot(
  mutate(
    select(
      filter(mpg, manufacturer == "audi"), model, cty, hwy), 
    avg = (cty + hwy)/2), 
  aes(model,avg)) + 
  geom_point() # Does the same as before
# It is possible but quite nested. You find the dataset in the inner part of the construction and
# the specification of aes() for the ggplot is far away from where the function ggplot stands.
# Writing thing in the pipe-way is quite adapted to a typical data science way of thinking:
# You start with the data, you do some modifications step-by-step and may even end in a visualization
# Bonus: You do not produce several temporary objects which you often do not need further but which 
# may confuse you and bother you with finding new names all the time. 








