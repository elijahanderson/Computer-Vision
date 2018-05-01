=begin
    This project will involve writing a program to perform various computer vision tasks
    using artificial intelligence.
=end

# declare vars for image info
WIDTH = 128
HEIGHT = 128
MAX_PIXEL = 255
original_pixels = Array.new(WIDTH, 0) { Array.new(HEIGHT, 0) }

# write pgm data to a pgm file
def write_to_pgm(to_write, pixels)
    # if it already exists, delete it and create a new one
    if File.file?(to_write)
        File.delete(to_write)
    end
    # begin writing
    File.open(to_write, "w") do |pgm|
        # store in P2 format
        pgm.write("P2\n#{WIDTH} #{HEIGHT}\n#{MAX_PIXEL}\n")
        pixels.each do |i|
            i.each do |pixel|
                pgm.write("#{pixel} ")
            end
        end
    end

end

# perform an average filter on a pgm image, save the result as 'average.pgm'
# => returns the 2D array of the filtered pixels
def filter_average(pixels)
    puts "Performing average filtering on your image..."
    avg_pixels = Array.new(WIDTH, 0) { Array.new(HEIGHT, 0) }

    pixels.each_with_index do |ph, i| # ph for placeholder
        ph.each_with_index do |pix_val, j|
            sum = pix_val # the center pixel value
            count = 1
            if i == 0 && j == 0 # top left corner pixel
                sum += pixels[i+1][j+1] + pixels[i][j+1] + pixels[i+1][j]
                count = 4
            elsif i == 0 && j == WIDTH-1 # top right corner pixel
                sum += pixels[i+1][j-1] + pixels[i][j-1] + pixels[i+1][j]
                count = 4
            elsif i == HEIGHT-1 && j == 0 # bottom left
                sum += pixels[i-1][j+1] + pixels[i-1][j] + pixels[i][j+1]
                count = 4
            elsif i == HEIGHT-1 && j == WIDTH-1 # bottom right
                sum += pixels[i-1][j] + pixels[i-1][j-1] + pixels[i][j-1]
                count = 4
            elsif i == 0 # top edge
                sum += pixels[i][j-1] + pixels[i+1][j-1] + pixels[i+1][j] + pixels[i+1][j+1] + pixels[i][j+1]
                count = 6
            elsif i == HEIGHT-1 # bottom edge
                sum += pixels[i][j-1] + pixels[i-1][j-1] + pixels[i-1][j] + pixels[i-1][j+1] + pixels[i][j+1]
                count = 6
            elsif j == 0 # left edge
                sum += pixels[i-1][j] + pixels[i-1][j+1] + pixels[i][j+1] + pixels[i+1][j+1] + pixels[i+1][j]
                count = 6
            elsif j == WIDTH-1 # right edge
                sum += pixels[i-1][j] + pixels[i-1][j-1] + pixels[i][j-1] + pixels[i+1][j-1] + pixels[i+1][j]
                count = 6
            else
                sum += pixels[i-1][j-1] + pixels[i-1][j] + pixels[i-1][j+1] + pixels[i][j+1] + pixels[i+1][j+1] +
                pixels[i+1][j] + pixels[i+1][j-1] + pixels[i][j-1]
                count = 9
            end
            # calculate the average
            avg = sum / count
            # set current pixel to average
            avg_pixels[i][j] = avg
        end
    end
    # write to 'average.pgm'
    write_to_pgm("average.pgm", avg_pixels)
    puts "Done."
    # return the average pixel set
    return avg_pixels
end

# perform an median filter on a pgm image, save the result as 'average.pgm'
# => returns the 2D array of the filtered pixels
def filter_median(pixels)
    puts "Performing median filtering on your image..."
    med_pixels = Array.new(WIDTH, 0) { Array.new(HEIGHT, 0) }

    pixels.each_with_index do |ph, i|
        ph.each_with_index do |pix_val, j|
            # array to store the current pixel and its 8 surrounding pixels
            around_town = []
            around_town.push(pix_val)
            if i == 0 && j == 0 # top left corner pixel
                around_town.push(pixels[i][j+1], pixels[i+1][j+1], pixels[i+1][j])
            elsif i == 0 && j == WIDTH-1 # top right corner pixel
                around_town.push(pixels[i][j-1], pixels[i+1][j-1], pixels[i+1][j])
            elsif i == HEIGHT-1 && j == 0 # bottom left
                around_town.push(pixels[i-1][j], pixels[i-1][j+1], pixels[i][j+1])
            elsif i == HEIGHT-1 && j == WIDTH-1 # bottom right
                around_town.push(pixels[i][j-1], pixels[i-1][j-1], pixels[i-1][j])
            elsif i == 0 # top edge
                around_town.push(pixels[i][j-1], pixels[i][j+1], pixels[i+1][j-1],
                    pixels[i+1][j], pixels[i+1][j+1])
            elsif i == HEIGHT-1 # bottom edge
                around_town.push(pixels[i-1][j-1], pixels[i-1][j], pixels[i-1][j+1],
                    pixels[i][j-1], pixels[i][j+1])
            elsif j == 0 # left edge
                around_town.push(pixels[i-1][j], pixels[i-1][j+1], pixels[i][j+1],
                    pixels[i+1][j], pixels[i+1][j+1])
            elsif j == WIDTH-1 # right edge
                around_town.push(pixels[i-1][j-1], pixels[i-1][j], pixels[i][j-1],
                    pixels[i+1][j-1], pixels[i+1][j])
            else
                around_town.push(pixels[i-1][j-1], pixels[i-1][j], pixels[i-1][j+1],
                    pixels[i][j-1], pixels[i][j+1], pixels[i+1][j-1], pixels[i+1][j], pixels[i+1][j+1])
            end

            # calculate the median value
            around_town.sort!
            len = around_town.length
            # works on both even and odd length arrays
            median = (around_town[(len-1)/2] + around_town[len/2]) / 2
            med_pixels[i][j] = median
        end
    end
    # write to 'median.pgm'
    write_to_pgm("median.pgm", med_pixels)
    puts "Done."
    # return the median pixels set
    return med_pixels
end

# perform edge detection on the image, save result as "edge.pgm"
# => returns the 2D array of the edge pixels
def detect_edges(pixels)
    puts "Performing edge detection on your image..."
    edge_pixels = Array.new(WIDTH, 0) { Array.new(HEIGHT, 0) }
    magnitudes = Array.new(WIDTH, 0) { Array.new(HEIGHT, 0) }

    pixels.each_with_index do |ph, i|
        ph.each_with_index do |pix_val, j|
            # ignore edge/corner pixels
            magnitude = 0
            if i != 0 && j != 0 && i != HEIGHT-1 && j != WIDTH-1
                # calculate delta x
                delta_x = (pixels[i-1][j+1] + pixels[i][j+1] + pixels[i+1][j+1]) -
                (pixels[i-1][j-1] + pixels[i][j-1] + pixels[i+1][j-1])
                # calculate delta y
                delta_y = (pixels[i-1][j-1] + pixels[i-1][j] + pixels[i-1][j+1]) -
                (pixels[i+1][j-1] + pixels[i+1][j] + pixels[i+1][j+1])
                # calculate magnitude
                magnitude = Math.sqrt((delta_x ** 2) + (delta_y ** 2)).to_i
            end
            magnitudes[i][j] = magnitude
        end
    end
    # flatten the 2D array to easily calculate average
    flattened_mag = magnitudes.flatten
    avg_mag = flattened_mag.inject {|sum, pix_val| sum + pix_val}.to_f / flattened_mag.size

    # loop through magnitudes, if pixel magnitude is greater than avg magnitude, fill the pixel in
    magnitudes.each_with_index do |ph, i|
        ph.each_with_index do |pix_mag, j|
            if pix_mag > avg_mag * 3
                edge_pixels[i][j] = 255
            end
        end
    end
    # write to 'edge.pgm'
    write_to_pgm("edge.pgm", edge_pixels)
    puts "Done"
    # return the set of edge pixels
    return edge_pixels
end

# Uses the Hough transform to detect lines, save the result as "lines.pgm"
def detect_lines(pixels)
    puts "Performing line detection on your image..."
    pix_lines = Hash.new # to keep track of lines for each pixel
    vert_lines = [] # to keep track of vertical lines
    pixels.each_with_index do |ph, i|
        ph.each_with_index do |pix_val, j|
            # for each edge pixel, find all possible lines that pass through that pixel
            if pix_val == 255
                # iterate through possible non-vertical lines
                m = -20.0
                while m <= 20.0
                    b = i - (j * m) # calculate intercept -- i = y (rows), j = x (cols)
                    line = [b, m]
                    # record occurance of the line in pix_lines
                    if pix_lines.has_key?(line)
                        pix_lines[line] += 1
                    else
                        pix_lines[line] = 1
                    end
                    m += 0.5
                end
                # check for vertical line
                count = 0
                if !vert_lines.include?(j) # if col doesn't already have a vertical line classified
                    for y in 0..HEIGHT-1
                        if pixels[y][j] == 255
                            count += 1
                        elsif pixels[y][j] == 0 && count >= 1 # break in the line
                            break # end loop, don't push the line
                        end
                        if count >= 35
                            vert_lines.push(j) # use col value to classify vertical lines
                        end
                    end
                end
            end
        end
    end
    lines = []
    # find top 5 lines
    lines = pix_lines.sort_by { |key, val| -val }.first(5).map(&:first)
    print lines
    # write to 'lines.pgm'
    write_lines("lines.pgm", pixels, lines, vert_lines)
    puts "Done."
end

def detect_circles(pixels)
    puts "Performing circle detection..."
    circle_count = Hash.new
    pixels.each_with_index do |ph, i|
        ph.each_with_index do |pix_val, j|
            # for each edge pixel, find all possible circles that pass through that pixel
            if pix_val == 255
                # iterate through all the possible origins of the circle
                for x_o in 0..WIDTH-1
                    for y_o in 0..HEIGHT-1
                        r = Math.sqrt(((j - x_o) ** 2) + ((i - y_o) ** 2)).to_i
                        if r >= 5 && r <= 60 # only count good sized circles
                            circle = [x_o, y_o, r]
                            if circle_count.has_key?(circle)
                                circle_count[circle] += 1
                            else
                                circle_count[circle] = 1
                            end
                        end
                    end
                end
            end
        end
    end
    print circle_count.sort_by { |key, val| -val }.first(20).map(&:first)
    puts "Done"
end

# draw the most common lines on the given image, save result as "lines.pgm"
def write_lines(to_write, pixels, lines, vert_lines)
    if File.file?(to_write)
        File.delete(to_write)
    end
    File.open(to_write, "w") do |pgm|
        # store in P2 format
        pgm.write("P2\n#{WIDTH} #{HEIGHT}\n#{MAX_PIXEL}\n")

        # write each line over the edge image
        lines.each do |line|
            puts "In line!"
            m = line[1].to_i # slope
            y = line[0].to_i # get initial y-intercept
            x = 0
            i = 0 # to keep track of iterations
            # horizontal lines
            if m == 0.0
                while x < WIDTH
                    puts "#{x}, #{y}"
                    pixels[y][x] = 150 # color it light gray
                    x += 1
                end
            elsif m > -1.0 && m < 1.0
                puts "#{x}, #{y}"
            elsif m < 0.0
                x = -y / m # solve x for when y is 0
                y = 0
                while y <= HEIGHT-1 && x >= 0
                    puts "#{x}, #{y}"
                    pixels[y][x] = 150
                    y -= m
                    x -= 1
                end
            else
                x = y / m
                y = 0
                while y <= HEIGHT-1 && x >=0
                    puts "#{x}, #{y}"
                    pixels[y][x] = 150
                    y += m
                    x -= 1
                end
            end
        end
        # vertical lines
        vert_lines.each do |col|
            for y in 0..HEIGHT-1
                pixels[y][col] = 150
            end
        end
        # write the updated pixel image
        pixels.each do |i|
            i.each do |pixel|
                pgm.write("#{pixel} ")
            end
        end
    end
end

# prompt the user to enter a .pgm format file name containing an image of a number (for this project)
puts "Enter a .pgm format file name: "
filename = gets.chop

# check for existence
if File.file?(filename)
    file = File.read(filename).split(" ") # store info in string array
    f_format = file[0]
    width = file[1].to_i
    height = file[2].to_i
    max_pixel = file[3].to_i

    if width != WIDTH || height != HEIGHT || max_pixel != MAX_PIXEL
        abort("Error in image format -- program terminated.")
    end
    if f_format == "P5"
        temp = Array.new(width, 0)
        file2 = File.read(filename)
        file2[15..file2.length-1].split("").each_with_index do |val, i|
            temp[i] = val.ord
        end
        # reshape the temp array to fit the 2D shape of original_pixels
        original_pixels = temp.each_slice(height).to_a
    # plain PGM
    elsif f_format == "P2"
        temp = Array.new(width, 0)
        # values are split by spaces
        file[15..file2.length-1].split(" ").each_with_index do |val, i|
            temp[i] = val
        end
        # reshape the temp array to fit the 2D shape of original_pixels
        original_pixels = temp.each_slice(height).to_a
    end
else
    abort("That file does not appear to exist -- program terminated.")
end

# perform average filter on selected image
average = filter_average(original_pixels)
median = filter_median(original_pixels)
# using median filtering has more precise edges, but more noise. Vice versa for average filtering
edges = detect_edges(median)
detect_lines(edges)
detect_circles(edges)
