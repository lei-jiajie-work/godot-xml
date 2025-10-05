extends Node

func parse_chapter_path(path : String, parent_file_location : String, include_names : bool = true) -> Dictionary:
	var file_location : String = path.split(":")[0]
	var parsed_path : String
	var chapter_name = path.split(".")[0]
	chapter_name = chapter_name.split("/")[-1].c_escape()
	
	match file_location:
			"self":
				var parent_base_directory : String = parent_file_location.rsplit("/", true, 1)[0] + "/"
				parsed_path = path.replace("self://", parent_base_directory)
			"res":
				# if the path is already res://, then we don't need to do anything
				parsed_path = path
			"exec":
				var exe_path : String = ResourceScriptLoader.executable_path
				parsed_path = path.replace("exec://", exe_path)
			_:
				push_error("Invalid file path: %s" %[path])
	
	if include_names:
		return {"path" : parsed_path, "name" : chapter_name}
	else:
		return {"path" : parsed_path}

func load_chapters(chapters : Array, parent_file : String) -> Dictionary:
	var chapter_data : Dictionary
	
	for chap in chapters:
		var parsed : Dictionary = parse_chapter_path(chap, parent_file, true)
		chapter_data[parsed["name"]] = load_xml(parsed["path"])
	
	return chapter_data

func load_xml(xml_file_path : String) -> Dictionary:
	var parser : XMLParser = XMLParser.new()
	parser.open(xml_file_path)
	
	var unclosed_nodes : Array
	var current_node : String
	var returned_data : Dictionary
	
	while parser.read() != ERR_FILE_EOF:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				var count : int = 1
				
				# for the memory magic to happen and for nesting
				current_node = parser.get_node_name()
				
				# for attributes
				var attributes : Dictionary
				
				for i in parser.get_attribute_count():
					attributes[parser.get_attribute_name(i)] = parser.get_attribute_value(i)
				
				# nesting magic, using the unenclosed array
				if unclosed_nodes.size() > 0:
					var path = returned_data
					
					# Finally solved nesting here
					path = path.get(unclosed_nodes[0])
					for i in range(1, unclosed_nodes.size()):
						path = path.get("children").get(unclosed_nodes[i])
					path = path["children"]
					
					if path.has(current_node + str(count)):
						while path.has(current_node + str(count)):
							count += 1
					current_node = current_node + str(count)
					path[current_node] = {
						"attributes" : attributes,
						"text" : "",
						"children" : {}
					}
				else:
					if returned_data.has(current_node + str(count)):
						while returned_data.has(current_node + str(count)):
							count += 1
						
					current_node = current_node + str(count)
					returned_data[current_node] = {
						"attributes" : attributes,
						"text" : "",
						"children" : {}
					}
				unclosed_nodes.append(current_node)
			XMLParser.NODE_ELEMENT_END:
				for i in range(unclosed_nodes.size() -1, -1, -1):
					if unclosed_nodes[i].begins_with(parser.get_node_name()):
						unclosed_nodes.remove_at(i)
						break
			XMLParser.NODE_TEXT:
				var text : String = parser.get_node_data().c_unescape()
				
				if unclosed_nodes.size() > 1:
					var path = returned_data
					
					path = path.get(unclosed_nodes[0])
					
					for i in range(1, unclosed_nodes.size()):
						path = path.get("children").get(unclosed_nodes[i])
					
					path["text"] = text
				else:
					returned_data[current_node]["text"] = text
	return returned_data
