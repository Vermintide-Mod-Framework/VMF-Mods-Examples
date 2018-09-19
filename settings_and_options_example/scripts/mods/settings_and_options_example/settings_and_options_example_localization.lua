return {

	-- OPTIONS WIDGETS

	setting_one = {
		en = "Setting One",
		ru = "Первый параметр"
	},
	setting_one_description = {
		en = "This mod doesn't need any tooltips, but I'm gonna insert a bunch of them just for an example.",
		ru = "Этот мод не нуждается ни в каких всплывающих подсказках, но я вставлю парочку ради примера."
	},
	setting_two = {
		en = "Setting Two [Parent Checkbox]",
		ru = "Второй параметр [Родительский чекбокс]"
	},
	setting_two_description = {
		en = "Well, this should be enough, I guess.",
		ru = "Пожалуй, хватит."
	},
	setting_three = {
		en = "Setting Three [Child Checkbox]",
		ru = "Третий параметр [Дочерний чекбокс]"
	},
	updating_approach_parent_dependant = {
		en = "Parent-dependant",
		ru = "Зависящий от родителя"
	},
	updating_approach_parent_independant = {
		en = "Parent-independant",
		ru = "Не зависящий от родителя" -- Bad choice of words. Won't fit in dropdown's box. Try not to do like this.
	},
	settings_updating_approach = {
		en = "Settings updating approach",
		ru = "Подход к получению реального значения параметров"
	},
	expression_group = {
		en = "Expression",
		ru = "Выражение"
	},
	expression_input = {
		en = "Arguments",
		ru = "Аргументы"
	},
	expression_input_none = {
		en = "None",
		ru = "Без аргументов"
	},
	expression_input_percent = {
		en = "Percent",
		ru = "Процент"
	},
	expression_input_number = {
		en = "Number",
		ru = "Номер"
	},
	expression_input_both = {
		en = "Number & Percent",
		ru = "Номер и процент"
	},
	expression_number = {
		en = "Some Number",
		ru = "Какой-то номер"
	},
	expression_percent = {
		en = "Some Percent",
		ru = "Какой-то процент"
	},
	unit_percentage = {
		 -- Note, that percent sign is escaped with another percent sign. This is necessity,
		 -- since string formatting in Lua has the same directives as 'printf' in C.
		 -- Also, note, that I don't provide localization for other languages, since '%' doesn't need to be translated,
		 -- and, if no translation for current game language is found, the game will always look for English translation.
		en = "%%"
	},
	solve_expression_keybind = {
		en = "Solve Expression",
		ru = "Найти значение выражения"
	},
	keybinds_group = {
		en = "Bunch of Keybinds",
		ru = "Кучка биндов"
	},

	-- MAIN SCRIPT

	show_active_settings_description = {
		en = "Show states",
		ru = "Показать состояния"
	},
	result = {
		en = "Result: %s",
		ru = "Результат: %s"
	},
}