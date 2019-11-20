a = [1,2,3,4,5]
b = [1,2,4,7,8,5,7]

c = (a & b).map{|e| a.find_index(e) }
p c.map { |i| a[i] }

