return function()
	local Pipe = require(script.Parent)

	describe("pipe", function()
		
		it("should send", function()
			local p = Pipe:New()

			local value = false

			p:Listen(function()
				value = true
			end)

			p:Send()

			expect(value).to.equal(true)
		end)

		it("should continue and mutate data", function()
			local p = Pipe:New()

			p:Listen(function(next, v)
				return next(v + 5)
			end)

			p:Listen(function(next, v)
				return next(v + 10)
			end)

			local value = p:Send(0)

			expect(value).to.equal(15)
		end)

		it("should follow priority", function()
			local p = Pipe:New()

			local t1, t2

			p:Listen(function(next)
				t1 = tick()
				task.wait()
				next()
			end, 2)

			p:Listen(function(next)
				t2 = tick()
				task.wait()
				next()
			end, 1)

			p:Send()

			expect(t1 > t2).to.equal(true)
		end)

		it("should allow non-consecutive priority", function()
			local p = Pipe:New()

			local t1, t2

			p:Listen(function(next)
				t1 = tick()
				task.wait()
				next()
			end, 5)

			p:Listen(function(next)
				t2 = tick()
				task.wait()
				next()
			end, 2)

			p:Send()

			expect(t1 > t2).to.equal(true)
		end)
	end)
end