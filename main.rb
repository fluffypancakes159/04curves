require_relative 'line'
require_relative 'matrix'
require_relative 'transform'
require_relative 'curve'

def main(default=601)
    out = Array.new(default) {Array.new(default, [0, 0, 0])}
    transform = ident(4)
    edges = Array.new(0)
    file_data = []
    # script()
    File.open('script.txt', 'r') {|file|
        file.each_line { |line|
            file_data.append(line.strip)
        }
    }
    while file_data.length > 0 
        current = file_data.shift # pop first element off array
        if current[0] == '#'
            next # continue in python
        elsif current == 'line'
            coords = file_data.shift.split(" ")
            add_edge(edges, *(coords.map {|x| x.to_f}))
        elsif current == 'ident'
            transform = ident(4)
        elsif current == 'scale'
            factors = file_data.shift.split(" ")
            mult(scale(*factors), transform)
        elsif current == 'move'
            dists = file_data.shift.split(" ")
            mult(trans(*dists), transform)
        elsif current == 'rotate'
            args = file_data.shift.split(" ")
            mult(rot(*args), transform)
        elsif current == 'apply'
            mult(transform, edges)
        elsif current == 'display'
            out = Array.new(default) {Array.new(default, [0, 0, 0])}
            draw_matrix(out, edges)
            save_ppm(out, default)
            `display image.ppm` # ` ` runs terminal commands
        elsif current == 'save'
            out_file = file_data.shift
            out = Array.new(default) {Array.new(default, [0, 0, 0])}
            draw_matrix(out, edges)
            save_ppm(out, default)
            `convert image.ppm #{out_file}`
        elsif current == 'circle'
            args = file_data.shift.split(" ")
            args.map! {|x| x.to_f} # ! actually replaces the array
            add_circle(edges, *args)
        elsif current == 'hermite'
            args = file_data.shift.split(" ")
            args.map! {|x| x.to_f}
            add_hermite(edges, *args)
        elsif current == 'bezier'
            args = file_data.shift.split(" ")
            args.map! {|x| x.to_f}
            add_bezier(edges, *args)
        end
    end
end

def save_ppm(ary, dim)
    File.open('image.ppm', 'w') {|file|
        file.write("P3\n#{dim}\n#{dim}\n255\n")
        ary.length.times {|i|
            ary[i].length.times{|j|
                3.times {|k|
                    # puts "#{i} #{j} #{k}"
                    file.write(ary[i][j][k].to_s + ' ')
                }
            }
        }
    }
end

def script()
    vertices = [[0, 250, 0], [0, 200, 0], [200, 0, 0], [0, 0, 200], [0, 0, -200], [-200, 0, 0], [0, -200, 0], [0, -250, 0]]
    File.open('script.txt', 'w') {|file|
=begin
        vertices.length.times {|x|
            x.times {|y|
                if x == y or x + y == vertices.length - 1 or (x == 7 and y == 1) or (x == 6 and y == 0) or (x == 1 and y == 0) or (x == 7 and y == 6)
                    next
                end
                file.write("line\n")
                file.write("#{vertices[x][0]} #{vertices[x][1]} #{vertices[x][2]} #{vertices[y][0]} #{vertices[y][1]} #{vertices[y][2]}\n")
            }
        }
        file.write("ident\n")
        file.write("rotate\nx 20\n")
        file.write("rotate\ny -20\n")
        file.write("apply\n")
=end 
        # file.write("circle\n0 0 0 100\n")
        file.write("hermite\n0 0 100 100 50 150 -10 100\n")
        # file.write("bezier\n100 100 0 0 125 250 150 125\n")
        file.write("display\n")
        file.write("save\nimage.png")
    }
end

main(500)
