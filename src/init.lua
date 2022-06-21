local Packages = script.Parent

local Object = require(Packages.object)

local Pipe = Object:Extend()

function Pipe:Constructor()
	self._CallbackList = {}
	self._HighestPriority = 0
end

function Pipe:Listen(Callback: (next: (...any) -> (), ...any) -> (), Priority: number?)
	Priority = Priority or 1

	if self._HighestPriority < Priority then
		self._HighestPriority = Priority
	end

	if self._CallbackList[Priority] == nil then
		self._CallbackList[Priority] = {}
	end

	self._CallbackList[Priority][#self._CallbackList[Priority] + 1] = Callback
end

function Pipe:Send(...)
	local Args = { ... }
	local Continue = false

	local i = 0
	while i < self._HighestPriority do
		i += 1

		for _, v in ipairs(self._CallbackList[i] or {}) do
			Continue = false

			local Value = { v(function(...)
				Continue = true
				return ...
			end, unpack(Args)) }

			if #Value ~= 0 then
				Args = Value
			end

			if Continue == false then
				return unpack(Args)
			end
		end
	end

	return unpack(Args)
end

function Pipe:Destroy()
	self._CallbackList = nil
	self._HighestPriority = nil
end

export type Pipe = Object.Object<{
	Listen: (self: Pipe, (next: (...any) -> (), ...any) -> (), Priority: number) -> (),
	Send: (...any) -> (...any),
	Destroy: () -> (),

	_CallbackList: { (next: (...any) -> (), ...any) -> () },
	_HighestPriority: number,
}>

return Pipe :: Pipe
